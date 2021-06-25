import 'package:bloc_base/bloc_base.dart';
import 'package:filesharing_logic/filesharing_logic_models.dart';
import 'package:rxdart/subjects.dart';
import 'package:sharezone/filesharing/file_sharing_api.dart';
import 'package:sharezone_utils/streams.dart';

class MoveFileBloc extends BlocBase {
  final CloudFile cloudFile;
  final FileSharingGateway fileSharingGateway;

  MoveFileBloc({this.cloudFile, this.fileSharingGateway}) {
    changeNewPath(cloudFile.path);
  }

  final _newPathSubject = BehaviorSubject<FolderPath>.seeded(FolderPath.root);
  Stream<FolderPath> get newPath => _newPathSubject;

  TwoStreams<FileSharingData, FolderPath> get moveFileState => TwoStreams(
        fileSharingGateway.folderGateway.folderStream(cloudFile.courseID),
        newPath,
      );

  Function(FolderPath) get changeNewPath => _newPathSubject.sink.add;

  Stream<bool> get isMoveFileAllowed => moveFileState.stream
      .map((streamSnapshot) => canMoveFile(streamSnapshot.data0));

  Future<void> moveFileToNewPath() async {
    if (canMoveFile(await fileSharingGateway.folderGateway
        .getFilesharingData(cloudFile.courseID)))
      fileSharingGateway.cloudFilesGateway
          .moveFile(cloudFile, _newPathSubject.value);
  }

  bool canMoveFile(FileSharingData fileSharingData) {
    final _pathValue = _newPathSubject.value;
    if (_pathValue == cloudFile.path) return false;
    if (fileSharingData.getFolder(_pathValue) == null) return false;

    return true;
  }

  @override
  void dispose() {
    _newPathSubject.close();
  }
}