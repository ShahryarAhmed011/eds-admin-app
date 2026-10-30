import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/core.dart';
import '../../data/data_sources/place_search.dart';

/// Opens the map to drop a pin by hand; returns the chosen point, or null
/// when the user backs out. [title] is the one-line instruction under the
/// coordinates.
Future<GeoPoint?> pickMapPin(
  BuildContext context, {
  GeoPoint? initial,
  String title = 'Drag the map so the pin sits on your shop.',
}) => Navigator.of(context).push<GeoPoint>(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => MapPinPickerScreen(initial: initial, title: title),
  ),
);

/// Full-screen OpenStreetMap with a fixed pin in the middle: search for a
/// place, drag the map under the pin, or jump to the device's location,
/// then "Confirm location".
class MapPinPickerScreen extends StatefulWidget {
  const MapPinPickerScreen({super.key, this.initial, required this.title});

  final GeoPoint? initial;
  final String title;

  /// Islamabad, when there's no pin yet.
  static const fallback = GeoPoint(33.6844, 73.0479);

  @override
  State<MapPinPickerScreen> createState() => _MapPinPickerScreenState();
}

class _MapPinPickerScreenState extends State<MapPinPickerScreen> {
  final _map = MapController();
  late LatLng _center = _toLatLng(
    widget.initial ?? MapPinPickerScreen.fallback,
  );
  bool _locating = false;

  final _places = NominatimPlaceSearch();
  final _query = TextEditingController();
  Timer? _debounce;
  // Only the latest search may show its results.
  int _searchSeq = 0;
  List<PlaceHit> _hits = const [];
  bool _noMatches = false;

  static const _zoom = 17.0;

  static LatLng _toLatLng(GeoPoint point) =>
      LatLng(point.latitude, point.longitude);

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _map.dispose();
    super.dispose();
  }

  /// Searches once typing pauses (Nominatim allows a request a second).
  void _onQueryChanged(String text) {
    _debounce?.cancel();
    final query = text.trim();
    if (query.isEmpty) {
      setState(() {
        _hits = const [];
        _noMatches = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () => _search(query));
  }

  Future<void> _search(String query) async {
    final seq = ++_searchSeq;
    List<PlaceHit> hits;
    try {
      hits = await _places.search(query);
    } catch (_) {
      hits = const [];
    }
    if (!mounted || seq != _searchSeq) return;
    setState(() {
      _hits = hits;
      _noMatches = hits.isEmpty;
    });
  }

  /// One zoom level in or out, keeping the pin where it is.
  void _zoomBy(double levels) {
    final camera = _map.camera;
    _map.move(camera.center, camera.zoom + levels);
  }

  /// Moves the map to the place; the pin stays centred, so the owner can
  /// still nudge it onto the exact spot.
  void _goTo(PlaceHit hit) {
    final point = _toLatLng(hit.point);
    _map.move(point, _zoom);
    _query.text = hit.name;
    FocusScope.of(context).unfocus();
    setState(() {
      _center = point;
      _hits = const [];
      _noMatches = false;
    });
  }

  /// The device's position (asking for permission), then the map moves
  /// there.
  Future<void> _locateMe() async {
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _toast('Turn on location services to find where you are.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _toast('Allow location access to find where you are.');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final here = LatLng(position.latitude, position.longitude);
      _map.move(here, _zoom);
      setState(() => _center = here);
    } catch (_) {
      _toast('Couldn’t find your location. Move the map instead.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _toast(String message) {
    if (mounted) EdsToast.show(context, message, kind: EdsToastKind.error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              onPositionChanged: (camera, _) =>
                  setState(() => _center = camera.center),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.eds.eds_mobile_app',
              ),
              const RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          // The pin stays in the middle; its tip marks the point.
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(
                  Icons.location_on,
                  size: 48,
                  color: AppColors.crimson,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _RoundButton(
                        icon: Icons.arrow_back,
                        tooltip: 'Back',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      AppSpacing.gapMd,
                      Expanded(
                        child: EdsSearchField(
                          hint: 'Search for a place, area or street',
                          controller: _query,
                          onChanged: _onQueryChanged,
                        ),
                      ),
                    ],
                  ),
                  if (_hits.isNotEmpty || _noMatches) ...[
                    AppSpacing.gapSm,
                    _PlaceResults(hits: _hits, onPick: _goTo),
                  ],
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _RoundButton(
                      icon: Icons.add,
                      tooltip: 'Zoom in',
                      onTap: () => _zoomBy(1),
                    ),
                    AppSpacing.gapSm,
                    _RoundButton(
                      icon: Icons.remove,
                      tooltip: 'Zoom out',
                      onTap: () => _zoomBy(-1),
                    ),
                    AppSpacing.gapSm,
                    _RoundButton(
                      icon: Icons.my_location,
                      tooltip: 'My location',
                      loading: _locating,
                      onTap: _locating ? null : _locateMe,
                    ),
                    AppSpacing.gapMd,
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.place_outlined,
                                color: AppColors.crimson,
                              ),
                              AppSpacing.gapSm,
                              Expanded(
                                child: Text(
                                  '${_center.latitude.toStringAsFixed(5)}, '
                                  '${_center.longitude.toStringAsFixed(5)}',
                                  style: AppTextStyles.itemTitle,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapXs,
                          Text(widget.title, style: AppTextStyles.caption),
                          AppSpacing.gapLg,
                          EdsButton.primary(
                            label: 'Confirm location',
                            onPressed: () => Navigator.of(context).pop(
                              GeoPoint(_center.latitude, _center.longitude),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The places a search found, on a white card under the search bar; empty
/// [hits] means the search found nothing.
class _PlaceResults extends StatelessWidget {
  const _PlaceResults({required this.hits, required this.onPick});

  final List<PlaceHit> hits;
  final ValueChanged<PlaceHit> onPick;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: Material(
          color: AppColors.none,
          child: hits.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'No places found. Try another name, or drag the map.',
                    style: AppTextStyles.bodySecondary,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < hits.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: AppSpacing.lg,
                          color: AppColors.border,
                        ),
                      InkWell(
                        onTap: () => onPick(hits[i]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.place_outlined,
                                size: 20,
                                color: AppColors.gray,
                              ),
                              AppSpacing.gapMd,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hits[i].name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.itemTitle,
                                    ),
                                    if (hits[i].detail.isNotEmpty)
                                      Text(
                                        hits[i].detail,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.caption,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

/// A white circle button floating over the map.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.white,
        shape: CircleBorder(side: BorderSide(color: AppColors.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 48,
            child: Center(
              child: loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.crimson,
                      ),
                    )
                  : Icon(icon, color: AppColors.crimson),
            ),
          ),
        ),
      ),
    );
  }
}
