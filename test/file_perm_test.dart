import 'package:noh_shell/utils/FilePerm.dart';
import 'package:test/test.dart';

void main() {
  group('FilePerm', () {
    test('Create from string - symbolic mode', () {
      var perm = FilePerm.fromString('u+rwx,g=rx,o-w');
      expect(perm.toString(), equals('rwxr-x---'));
      expect(perm.toOctal(), equals('750'));
    });

    test('Create from string - numeric mode', () {
      var perm = FilePerm.fromString('755');
      expect(perm.toString(), equals('rwxr-xr-x'));
      expect(perm.toOctal(), equals('755'));
    });

    test('Create from integer', () {
      var perm = FilePerm.fromInt(int.parse('644', radix: 8));
      expect(perm.toString(), equals('rw-r--r--'));
      expect(perm.toOctal(), equals('644'));
    });

    test('Parse complex symbolic mode', () {
      var perm = FilePerm.fromString('u=rwx,g=rx,o=r,+t');
      expect(perm.toString(), equals('rwxr-xr-T'));
      expect(perm.toOctal(), equals('1754'));
    });

    test('Check individual permissions', () {
      var perm = FilePerm.fromString('rwxr-xr-x');
      expect(perm.userCanRead, isTrue);
      expect(perm.userCanWrite, isTrue);
      expect(perm.userCanExecute, isTrue);
      expect(perm.groupCanRead, isTrue);
      expect(perm.groupCanWrite, isFalse);
      expect(perm.groupCanExecute, isTrue);
      expect(perm.othersCanRead, isTrue);
      expect(perm.othersCanWrite, isFalse);
      expect(perm.othersCanExecute, isTrue);
    });

    test('Set individual permissions', () {
      var perm = FilePerm.fromString('rwxr-xr-x');
      perm.setUserWrite(false);
      perm.setGroupExecute(false);
      expect(perm.toString(), equals('r-xr-xr-x'));
      expect(perm.toOctal(), equals('554'));
    });

    test('Handle special permissions', () {
      var perm = FilePerm.fromString('rwsr-sr-t');
      expect(perm.toOctal(), equals('7754'));
      expect(perm.hasSetuid, isTrue);
      expect(perm.hasSetgid, isTrue);
      expect(perm.hasSticky, isTrue);
    });

    test('Convert between representations', () {
      var perm = FilePerm.fromString('rwxr-xr-x');
      expect(perm.toOctal(), equals('755'));
      expect(FilePerm.fromString(perm.toOctal()).toString(), equals('rwxr-xr-x'));
    });
  });
}
