import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/admin_inputs.dart';
import 'admin_form_scaffold.dart';
import 'admin_point_form_view_model.dart';

/// Crear (`/admin/points/new`) o editar (`/admin/points/:pointId`) un tacho.
class AdminPointFormView extends StatelessWidget {
  const AdminPointFormView({super.key, this.pointId});

  final String? pointId;

  @override
  Widget build(BuildContext context) {
    final deps = context.read<AppDependencies>();
    return ChangeNotifierProvider(
      key: ValueKey(pointId),
      create: (_) => AdminPointFormViewModel(
        admin: deps.local.admin!,
        entityId: pointId,
        locate: deps.locate,
      )..load(),
      child: const _PointForm(),
    );
  }
}

class _PointForm extends StatefulWidget {
  const _PointForm();

  @override
  State<_PointForm> createState() => _PointFormState();
}

class _PointFormState extends State<_PointForm> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _occupancy = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();

  late final AdminPointFormViewModel _vm = context
      .read<AdminPointFormViewModel>();

  void _syncAll() {
    _name.text = _vm.name;
    _description.text = _vm.description;
    _occupancy.text = _vm.occupancyText;
    _syncCoordinates();
  }

  void _syncCoordinates() {
    _latitude.text = _vm.latitudeText;
    _longitude.text = _vm.longitudeText;
  }

  Future<void> _locate() async {
    if (await _vm.useCurrentLocation() && mounted) _syncCoordinates();
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _occupancy, _latitude, _longitude]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormScaffold(
      viewModel: _vm,
      newTitle: 'Nuevo tacho',
      editTitle: 'Editar tacho',
      entityName: 'tacho',
      onEditingStarted: _syncAll,
      fields: (context) {
        final vm = context.watch<AdminPointFormViewModel>();
        const coordinates = TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        );
        return [
          TextField(
            key: const Key('point-name'),
            controller: _name,
            onChanged: vm.setName,
            maxLength: AdminLimits.pointNameMax,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Nombre',
              errorText: vm.nameError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const Key('point-description'),
            controller: _description,
            onChanged: vm.setDescription,
            maxLength: AdminLimits.descriptionMax,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Descripción (opcional)',
              errorText: vm.descriptionError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const Key('point-occupancy'),
            controller: _occupancy,
            onChanged: vm.setOccupancy,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Ocupación (%)',
              errorText: vm.occupancyError,
              suffixText: '%',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: vm.locating ? null : _locate,
            icon: vm.locating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              vm.locating ? 'Obteniendo ubicación…' : 'Usar mi ubicación',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('point-latitude'),
                  controller: _latitude,
                  onChanged: vm.setLatitude,
                  keyboardType: coordinates,
                  decoration: InputDecoration(
                    labelText: 'Latitud',
                    errorText: vm.latitudeError,
                    errorMaxLines: 3,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  key: const Key('point-longitude'),
                  controller: _longitude,
                  onChanged: vm.setLongitude,
                  keyboardType: coordinates,
                  decoration: InputDecoration(
                    labelText: 'Longitud',
                    errorText: vm.longitudeError,
                    errorMaxLines: 3,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ];
      },
    );
  }
}
