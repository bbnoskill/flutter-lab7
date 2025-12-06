abstract class AppStrings {
  const AppStrings._();

  static const String appTitle = 'Notebook';

  // Auth
  static const String login = 'Вхід';
  static const String register = 'Реєстрація';
  static const String email = 'Email';
  static const String emailHint = 'Введіть ваш email';
  static const String password = 'Пароль';
  static const String passwordHint = 'Введіть пароль';
  static const String loginButton = 'Увійти';
  static const String registerButton = 'Зареєструватися';


  // Validation
  static const String emailEmptyError = 'Email не може бути порожнім';
  static const String emailInvalidError = 'Введіть коректний email';
  static const String passwordEmptyError = 'Пароль не може бути порожнім';
  static const String passwordLengthError = 'Пароль має бути мін. 6 символів';

  // Errors
  static const String unknownError = 'Виникла невідома помилка';
  static const String errorInvalidCredential = 'Неправильний email або пароль. Перевірте дані та спробуйте ще раз.';
  static const String emailInUse = 'Цей email вже використовується';
}
