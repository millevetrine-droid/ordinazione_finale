import 'package:flutter_test/flutter_test.dart';
import 'package:ordinazione/core/providers/menu_provider.dart';
import 'package:ordinazione/core/repositories/menu_repository.dart';

void main() {
  test('MenuProvider loads macrocategorie', () async {
    final repo = MenuRepository();
    final provider = MenuProvider(repo);

    expect(provider.loading, isFalse);
    final future = provider.loadMacrocategorie();
    expect(provider.loading, isTrue);
    await future;
    expect(provider.loading, isFalse);
    expect(provider.macrocategorie, isNotEmpty);
  });
}
