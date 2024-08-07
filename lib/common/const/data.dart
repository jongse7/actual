import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

// 에뮬레이터의 로컬호스트
final emulatorIp = '10.0.2.2:3030';
// 시뮬레이터의 로컬호스트
final simulatorIp = '127.0.0.1:3030';
// 운영체제에 따라 IP 바꾸기
final ip = Platform.isIOS ? simulatorIp : emulatorIp;