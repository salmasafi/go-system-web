import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/end_point.dart';
import '../../../core/services/cache_helper.dart.dart';
import '../../../core/services/dio_helper.dart';
import '../../../core/utils/error_handler.dart';
import '../data/models/user_model.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  static LoginCubit get(context) => BlocProvider.of(context);

  UserModel? userModel;

  Future<void> userLogin({
    required String email,
    required String password,
  }) async {
    emit(LoginLoading());

    try {
      log('Starting login request...');

      final response = await DioHelper.postData(
        url: EndPoint.login,
        data: {'email': email, 'password': password},
      );

      log('Response received: ${response.statusCode}');
      DioHelper.printResponse(response);
      log(response.data.toString());

      if (response.statusCode == 200) {
        userModel = UserModel.fromJson(response.data);

        if (userModel?.success == true && userModel?.data != null) {
          // Save token
          if (userModel!.data!.token != null) {
            await CacheHelper.saveData(
              key: 'token',
              value: userModel!.data!.token,
            );
            log('Token saved successfully');
          }
          // // Save user data
          // if (userModel!.data!.user != null) {
          //   await CacheHelper.saveModel<User>(
          //     key: 'user',
          //     model: userModel!.data!.user!,
          //     toJson: (user) => user.toJson(),
          //   );
          //   log('User data saved successfully');
          // }

          log('Login successful');
          emit(LoginSuccess());
        } else {
          final errorMessage = userModel?.data?.message ?? 'Login failed';
          log('Login failed: $errorMessage');
          emit(LoginError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Response error: $errorMessage');
        emit(LoginError(errorMessage));
      }
    } catch (error) {
      log('Login error caught: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(LoginError(errorMessage));
    }
  }

  // Get saved token
  String? getSavedToken() {
    return CacheHelper.getData(key: 'token');
  }

  // Get saved user
  User? getSavedUser() {
    return CacheHelper.getModel<User>(
      key: 'user',
      fromJson: (json) => User.fromJson(json),
    );
  }

  // // Logout
  // Future<void> logout() async {
  //   try {
  //     await CacheHelper.removeData(key: 'token');
  //     await CacheHelper.removeData(key: 'user');
  //     userModel = null;
  //     emit(LoginInitial());
  //     log('Logout successful');
  //   } catch (error) {
  //     log('Logout error: $error');
  //   }
  // }

  // Check if user is logged in
  bool isLoggedIn() {
    final token = getSavedToken();
    return token != null && token.isNotEmpty;
  }
}
