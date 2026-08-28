sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

class OfflineFailure extends Failure {
  const OfflineFailure() : super('لا يوجد اتصال — العمل محفوظ محلياً');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('انتهت الجلسة، سجّل الدخول مرة أخرى');
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'هذا التقرير متاح للمدير فقط']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'تعذر إكمال الطلب']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
