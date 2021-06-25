import 'package:design/design.dart';
import 'package:group_domain_models/group_domain_models.dart';
import 'package:meta/meta.dart';

class GroupInfoWithSelectionState {
  final String id;
  final GroupType groupType;
  final String name;
  final Design design;
  final String abbreviation;
  final bool isSelected;

  const GroupInfoWithSelectionState({
    @required this.id,
    @required this.groupType,
    @required this.name,
    @required this.abbreviation,
    @required this.design,
    @required this.isSelected,
  });

  factory GroupInfoWithSelectionState.fromData(Map<String, dynamic> data) {
    return GroupInfoWithSelectionState(
      id: data['id'],
      groupType: groupTypeFromString(data['groupType']),
      name: data['name'],
      abbreviation: data['abbreviation'],
      design: Design.fromData(data['design']),
      isSelected: data['isPreSelected'],
    );
  }

  GroupKey get groupKey => GroupKey(id: id, groupType: groupType);

  GroupInfoWithSelectionState copyWithSelectionState(bool newSelectionState) {
    return GroupInfoWithSelectionState(
      id: id,
      groupType: groupType,
      name: name,
      abbreviation: abbreviation,
      design: design,
      isSelected: newSelectionState,
    );
  }
}