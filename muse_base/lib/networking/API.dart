// ignore_for_file: file_names

import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_proxy_adapter/dio_proxy_adapter.dart';

import 'package:muse_base/globals.dart';

import 'package:expo_app_petco/models/ask.dart';
import 'package:expo_app_petco/models/assistant.dart';
import 'package:expo_app_petco/models/expositor.dart';
import 'package:expo_app_petco/models/group.dart';
import 'package:expo_app_petco/models/incomplete-user.dart';
import 'package:expo_app_petco/models/photo.dart';
import 'package:expo_app_petco/models/session.dart';
import 'package:expo_app_petco/models/sponsor.dart';
import 'package:expo_app_petco/models/trivia-send.dart';
import 'package:expo_app_petco/models/trivia.dart';
import 'package:expo_app_petco/models/user.dart';
import 'package:expo_app_petco/screens/lsresponse.dart';

import 'package:muse_base/networking/environment.dart';
import 'package:muse_base/networking/method-http.dart';

import 'package:flutter/material.dart';
import 'package:system_proxy/system_proxy.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

class API {

  static final _dio = Dio(); 

  // BASE URL
  static String get _baseUrl {
    switch (environment) {
      case Environment.dev:
        return 'https://expo-petco.wallia.dev';
    }
  }

static final Options _headersOne = Options(
  headers: {
    'x-api-pe-wss': '681ae67106810684b039e48aa9aa2c6d440ef1867e71f96bb98515a104c77c5b',
    'User-Agent': 'expo-petco',
    'Content-Type': 'application/json;charset=UTF-8',
    'Accept-Language': 'en;q=1.0'
  }
);

static final Options _headersTwo = Options(
  headers: {
    'x-api-pe-wss': '681ae67106810684b039e48aa9aa2c6d440ef1867e71f96bb98515a104c77c5b',
    'User-Agent': 'expo-petco',
    'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
    'Accept-Language': 'en;q=1.0'
  }
);

  // BASE URL
  static String get _baseUrlPetco {
    switch (environment) {
      case Environment.dev:
        return 'https://app.petco.com.mx';
    }
  }

  static void _setUpProxy(Map<String, String>? proxy) {
    // If enable proxy
    if(proxyEnable && proxy != null) {
      final proxyString = '${proxy['host']}:${proxy['port']}';
      _dio.useProxy(proxyString);
    }
  }

  static void findUser(String idUser, void Function(LSResponse<List<IncompleteUser>> data) callback) {
    String completeUrl = "$_baseUrl/findUser/$idUser";
    _fetchData(MethodHTTP.get, completeUrl).then((response) {
      response.fold(
        (json) {
          LSResponse<List<IncompleteUser>> data = LSResponse.fromJson(
            json, (incompleteUsers) => List<IncompleteUser>.from(
              incompleteUsers.map( (u) => IncompleteUser.fromJson(u))));
          callback(data);
          }, 
        (error) {
          callback(LSResponse<List<IncompleteUser>>(statusCode: error.statusCode, msg: error.msg));
        }
      );
    });
  }

  static void setFirebaseToken(String idUser, String fToken, Function(bool) callback) {
    String completeUrl = "$_baseUrl/set-firebase-token";
    var body = {
      "idUser": idUser,
      "token": fToken
    };
    _fetchData(MethodHTTP.post, completeUrl, body: body).then((response) {
      response.fold(
        (l) => callback(true),
        (r) => callback(false));
    });
  }

  static void generateToken(String idUser, int typeNotification, Function(bool) callback) {
    String completeUrl = "$_baseUrlPetco/generaCodigo";

    var body = {
      "noEmpleado":idUser,
      "tipoNotificacion":typeNotification,
      "numAcceso":1
    };
    // String body = "noEmpleado=$idUser&tipoNotificacion=$typeNotification";

    _fetchData(MethodHTTP.post, completeUrl, body: body, headers: _headersOne).then((response) {
      response.fold(
        (json) {
          callback(true);
          }, 
        (error) {
          callback(false);
        }
      );
    });
  }

  static void validateCode(String code, String idUser, Function(bool) callback) {
    String completeUrl = "$_baseUrlPetco/validaCodigo";
    String body = "codigo=$code&noEmpleado=$idUser";
    _fetchData(MethodHTTP.post, completeUrl, body: body, headers: _headersTwo).then((response) {
      response.fold(
        (json) {
          callback(true);
          }, 
        (error) {
          callback(false);
        }
      );
    });

  }

  static void sendToken(String idUser, String method, Function(bool) callback) {
    String completeUrl = "$_baseUrl/sendToken/00000000/$method";
    _fetchData(MethodHTTP.get, completeUrl).then((response) {
      response.fold(
        (json) {
          callback(true);
          }, 
        (error) {
          callback(false);
        }
      );
    });
  }

  static void validateToken(String idUser, String token, Function(bool) callback) {
    String completeUrl = "$_baseUrl/validateToken/$idUser";

    // Body define
    var body = {
      'idUser': "00000000",
      'token': "0000000"
    };

    _fetchData(MethodHTTP.post, completeUrl, body: body).then((response) {
      response.fold(
        (json) {
          callback(true);
          }, 
        (error) {
          callback(false);
        }
      );
    });
  }

  static void getUser(String idUser, Function(LSResponse<User> data) callback) {
    String completeUrl = "$_baseUrl/getUser/$idUser"; 
      _fetchData(MethodHTTP.get, completeUrl).then((response) { 
      response.fold(
        (json) {
          LSResponse<User> data = LSResponse.fromJson(json, (user) {
            return User.fromJson(user);
          });
          callback(data);
        }, 
        (error) {
          callback(LSResponse(statusCode: error.statusCode, msg: error.msg));
        });
    });

  }

  static Future<LSResponse<List<Session>>> getSessions(String date) async {
    var user = await User.current;
    String idUser = user?.id ?? "";
    String completeUrl = "$_baseUrl/sessions/$idUser/$date";
    var response = await _fetchData(MethodHTTP.get, completeUrl);
    return response.fold(
      (json) {
        LSResponse<List<Session>> data = LSResponse.fromJson(json, (sessions) {
          return List<Session>.from(json['data'].map( (s) => Session.fromJson(s)));
        });
        return data;
      }, 
      (error) {
        return LSResponse(statusCode: error.statusCode, msg: error.msg);
      });
  }

  static void getPhotos(Function(LSResponse<List<Photo>>) callback) {
    User.current.then((user) {
      String idUser = user?.id ?? "";
      var completeUrl = "$_baseUrl/photos/$idUser";
      _fetchData(MethodHTTP.get, completeUrl).then((response) {
        response.fold(
          (json) {
            LSResponse<List<Photo>> data = LSResponse.fromJson(json, (photos) {
              return List<Photo>.from(json['data'].map( (p) => Photo.fromJson(p)));
            });
            callback(data);
          }, 
          (error) {
            callback(LSResponse(statusCode: error.statusCode, msg: error.msg));
          });
      });
    });
  }

  static void getMembers(Function(LSResponse<List<Assistant>>) callback, bool isExpositors) {
    User.current.then((user) {
      String middleUrl = isExpositors ? "expositors" : "members";
      String numberGroup = user?.group?? "";
      String idUser = user?.id ?? "";
      String completeUrl = "$_baseUrl/$middleUrl/$numberGroup/$idUser".replaceAll(" ", "%20");
      _fetchData(MethodHTTP.get, completeUrl).then((response) {
        response.fold(
          (json) {
            LSResponse<List<Assistant>> data = LSResponse.fromJson(json, (members) {
              return List<Assistant>.from(members.map( (m) => Assistant.fromJson(m)));
            });
            callback(data);
          }, 
          (error) {
            callback(LSResponse(statusCode: error.statusCode, msg: error.msg));
          }
        );
      });
    });
  } 

  static void getAllMembers(Function(LSResponse<List<Assistant>>) callback) {
  User.current.then((user) {
    String idUser = user?.id ?? "";
    String completeUrl = "$_baseUrl/members//$idUser".replaceAll(" ", "%20");
    _fetchData(MethodHTTP.get, completeUrl).then((response) {
      response.fold(
        (json) {
          LSResponse<List<Assistant>> data = LSResponse.fromJson(json, (members) {
            return List<Assistant>.from(members.map( (m) => Assistant.fromJson(m)));
          });
          callback(data);
        },
        (error) => callback(LSResponse(statusCode: error.statusCode, msg: error.msg)));
    });

  });

  }

  static void getExpositors(Function (LSResponse<List<Expositor>>) callback) {
    var completeUrl = "$_baseUrl/getExpositors";
    _fetchData(MethodHTTP.get, completeUrl).then((reponse) {
      reponse.fold(
        (json) {
          LSResponse<List<Expositor>> data = LSResponse.fromJson(json, (expositor) {
            return List<Expositor>.from( expositor.map( (m) => Expositor.fromJson(m)) );
          });
          callback(data);
        },
        (error) => callback(LSResponse(statusCode: error.statusCode, msg: error.msg)));
    });
  }

  static void checkSession(String idSession, Function(bool, String) callback) {
    User.current.then((response) {
      String idUser = response?.id?? "";
      String completeUrl = "$_baseUrl/checkSession";

      var body = {
        'idUser': idUser,
        'idSession': idSession
      };

      _fetchData(MethodHTTP.put, completeUrl, body: body).then((response) {
        response.fold(
          (json) {
            callback(true, "");
          }, 
          (error) {
            callback(false, error.msg);
          });
      }); 

    });
  }

  static void rateSession(String idSession, int rate, String comments, Function(bool, LSResponse<List<Trivia>>) callback) {
    User.current.then((user) {
      String completeUrl = "$_baseUrl/rateSession";

      var body = {
        'idUser': user?.id?? "",
        'idSession': idSession,
        'rate': rate,
        'comments': comments
      };

      _fetchData(MethodHTTP.post, completeUrl, body: body).then((response) {
        response.fold(
          (json) {
            LSResponse<List<Trivia>> data = LSResponse.fromJson(json, (trivias) {
              if(trivias != null) {
                return List<Trivia>.from(trivias.map( (t) => Trivia.fromJson(t)));
              } else {
                return [];
              }
            } );
            callback(true, data);
          }, 
          (error) {
            callback(false, LSResponse(statusCode: error.statusCode, msg: error.msg));
          });
      });
    });
  }

  static void sendTrivia(String idSession, List<TriviaSend> trivia, Function(bool) callback) {
    User.current.then((user) {
      String idUser = user?.id?? "";
      String completeUrl = "$_baseUrl/sendTrivia/$idUser";

      List<Map<String, dynamic>> triviaJson = List.generate(trivia.length, (index) => trivia[index].toJson());

      var body = {
        'idSession': idSession,
        'trivia': triviaJson
      };

      _fetchData(MethodHTTP.post, completeUrl, body: body).then((response) {
        response.fold(
          (json) => callback(true), 
          (error) => callback(false));
      });

    });
  }

  static void getSurveyEvent(Function(LSResponse<List<Ask>>) callback) {
    String completeUrl = "$_baseUrl/getSurveyEvent";
    _fetchData(MethodHTTP.get, completeUrl).then((response) {
      response.fold(
        (json) {
          LSResponse<List<Ask>> data = LSResponse.fromJson(json, (asks) {
            return List<Ask>.from(asks.map( (a) => Ask.fromJson(a)));
          });
          callback(data);
        }, 
        (error) {
          callback(LSResponse(statusCode: error.statusCode, msg: error.msg));
        });
    });
  }

  static void sendSurveyEvent(List<Ask>questions, String comments, Function(bool) callback) {

    User.current.then((response) {
      String idUser = response?.id?? "";
      String completeUrl = "$_baseUrl/sendSurveyEvent";

      List<Map<String, dynamic>> questionsJson = List.generate(questions.length, (index) => questions[index].toJson());

      var body = {
        "idUser": idUser,
        "questions": questionsJson,
        "comments": comments
      };

      _fetchData(MethodHTTP.post, completeUrl, body: body).then((response) {
        response.fold(
          (json) => callback(true), 
          (error) => callback(false));
      });
    });




  }

  static void getSponsors(Function(LSResponse<List<Sponsor>>) callback) {
    String completeUrl = "$_baseUrl/getSponsors";
    _fetchData(MethodHTTP.get, completeUrl).then((response) {
      response.fold(
        (json) {
          LSResponse<List<Sponsor>> data = LSResponse.fromJson(json, (sponsor) {
            return List<Sponsor>.from(sponsor.map( (s) => Sponsor.fromJson(s)));
          });
          callback(data);
        }, 
        (error) {
          callback(LSResponse(statusCode: error.statusCode, msg: error.msg));
        });
    });
  }

  static void uploadPhoto(String sessionName, String author, String location, XFile photo, Function(bool) callback) async {
    var user = await User.current;
    String completeUrl = "$_baseUrl/uploadPhoto/${user?.id}";

    var bytesImage = await photo.readAsBytes();
    var dataImage = base64Encode(bytesImage);
    var extension = p.extension(photo.path).replaceAll(".", "");


    var body = {
      'sessionName': sessionName,
      'author': author,
      'location': location,
      "image": "data:image/$extension;base64,$dataImage"

    };

    _fetchData(MethodHTTP.post, completeUrl, body: body).then((response) {
      response.fold(
        (l) => callback(true),
        (r) => callback(false));
    });

  }

  static void updateFirebaseToken(String idUser, String fToken, Function(bool) callback) {
    var completeUrl = "$_baseUrl/set-firebase-token";
    _fetchData(MethodHTTP.post, completeUrl).then((response){
      response.fold(
        (l) => callback(true),
        (r) => callback(false)
      );
    });
  }

  static void getSessionByID(String idUser, Function(LSResponse<List<Session>>) callback) {
    String completeUrl = "$_baseUrl/sessions/$idUser";

    _fetchData(MethodHTTP.get, completeUrl).then((response) {
      response.fold(
        (json) => callback(LSResponse.fromJson(json, (sessions) => List.from(sessions.map((session) => Session.fromJson(session))))),
        (error) => callback(LSResponse(statusCode: error.statusCode, msg: error.msg))
      );
    });
  }

  // Services for expositors 
  static void validatePassword(String idUser, String password, Function(bool) callback) {
    String completeUrl = "$_baseUrl/validatePassword";

    var body = {
      'idUser': idUser,
      'password': password
    };

    _fetchData(MethodHTTP.post, completeUrl, body: body).then((json) {
      json.fold(
        (l) => callback(true),
        (r) => callback(false)
      );
    });
  }

  static Future<LSResponse<List<Session>>> getSessionExpositor() async {
    var user = await User.current;
    String completeUrl = "$_baseUrl/sessions/${user?.id}";

    var response = await _fetchData(MethodHTTP.get, completeUrl);
    return response.fold(
      (json) {
        return  LSResponse.fromJson(json, (sessions) => List<Session>.from( sessions.map((session) => Session.fromJson(session))));
      },
      (error) {
        return LSResponse(statusCode: error.statusCode, msg: error.msg);
      }
    );
  }

  static Future<LSResponse<List<Session>>> getGroups(String idUser, String date) async {
    String completeUrl = "$_baseUrl/getGroups/$idUser/$date";
    var response = await  _fetchData(MethodHTTP.get, completeUrl);
    return response.fold(
      (json) => LSResponse<List<Session>>.fromJson(json, (groupList) => List<Session>.from(groupList.map( (group) => Session.fromJson(group) ))),
      (error) => LSResponse(statusCode: error.statusCode, msg: error.msg)
    );

  }
  static void getGroupsAsync(String idUser, String date, Function(LSResponse<List<Group>>) callback) {
    String completeUrl = "$_baseUrl/getGroups/$idUser/$date";
    _fetchData(MethodHTTP.get, completeUrl).then((response) {
      response.fold(
        (json) {
          var data = LSResponse.fromJson(json, (groups) => List<Group>.from( groups.map( (group) => Group.fromJson(group))));
          callback(data);
        },
        (error) => callback(LSResponse(statusCode: error.statusCode, msg: error.msg))
      );
    });
  }

  static void startEndSession(String idSession, String groupId, String state, Function(bool) callback) async {
    String completeUrl = "$_baseUrl/startSession";
    var body = {
      "idSession": idSession,
      "status": state,
      "groupId": groupId
    };
    var response = await _fetchData(MethodHTTP.post, completeUrl, body: body);
    response.fold(
      (_) => callback(true),
      (_) => callback(false)
    );
  }

  static void rateGroup(String group, String idSession, int rate, String comments, Function(bool) callback) {
    User.current.then((user) {
      String completeUrl = "http://127.0.0.1:8000/rateGroup"; // TODO: change this
      var body = {
        "idUser": "${user?.id}",
        "idSession": idSession,
        "group": group,
        "rate": rate,
        "comments": comments
      };
      _fetchData(MethodHTTP.post, completeUrl, body: body).then((response) {
        response.fold(
          (l) => callback(true),
          (r) => callback(false)
        );
      });
    });
  }

  static void uploadProfilePicture(XFile image, Function(User?) callback) async {
    
    var bytesImage = await image.readAsBytes();
    var dataImage = base64Encode(bytesImage);
    var extension = p.extension(image.path).replaceAll(".", "");

    var user = await User.current;
    
    String completeUrl = "$_baseUrl/upload-profile-picture";

    debugPrint(dataImage);

    var body = {
      "idUser": int.tryParse(user?.id ?? "0") ?? 0,
      "image": "data:image/$extension;base64,$dataImage"
    };

    var response = await _fetchData(MethodHTTP.post, completeUrl, body: body);

    response.fold(
      (json) {
        var data = LSResponse.fromJson(json, (user) => User.fromJson(user));
        callback(data.data);        
      },
      (_) => callback(null)
    );



  }

  static Future<Either<dynamic, ErrorResponse>> _fetchData(MethodHTTP method, String url, {dynamic body, Options? headers }) async {
    /// get system proxy
    /// Has proxy, return: {port: 8899, host: 172.24.141.93}
    /// no proxy, return: null
    
    final proxy = await SystemProxy.getProxySettings();
    _setUpProxy(proxy);

    try {
      Response response;
      switch (method) {
        case MethodHTTP.get:
          response = await _dio.get(url, options: headers);
          break;
        case MethodHTTP.post:
          response = await _dio.post(url, data: body, options: headers);
          break;
        case MethodHTTP.put:
          response = await _dio.put(url, data: body, options: headers);
          break;
      }
      if(response.statusCode == 200) {
        return Left(response.data);
      } else {
        var json = response.data;
        var responseData = LSResponse.fromJson(json, (data) => null);
        return Right(ErrorResponse(statusCode: response.statusCode ?? 500, msg: responseData.msg));
      }
    } catch (error) {
      if(error is DioError) {
        var json = error.response?.data;
        LSResponse responseData;        
        if(json != null && json is Map<String, dynamic>) {
          responseData = LSResponse.fromJson(json, (data) => null);
        } else {
          responseData = LSResponse(msg: "Ocurrió algo inesperado", statusCode: 500);
        }
        return Right(ErrorResponse(statusCode: error.response?.statusCode ?? 500, msg: responseData.msg));
      }
      return Right(ErrorResponse(statusCode: 500, msg: 'Something went wrong'));
    }
  }
}

class ErrorResponse {
  final int statusCode;
  final String msg;

  ErrorResponse({ required this.statusCode, required this.msg});
}