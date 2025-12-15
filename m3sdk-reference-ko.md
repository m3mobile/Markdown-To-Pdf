# M3 SDK 레퍼런스 가이드

## 목차

- [1. KeyTool SDK](#1-keytool-sdk)
  - [1.1 FN 키 제어 SDK](#11-fn-키-제어-sdk)
  - [1.2 키 설정 SDK](#12-키-설정-sdk)
- [2. Startup SDK](#2-startup-sdk)
  - [2.1 앱 관리](#21-앱-관리)
    - [2.1.1 APK 설치 SDK](#211-apk-설치-sdk)
    - [2.1.2 앱 활성화/비활성화 SDK](#212-앱-활성화비활성화-sdk)
    - [2.1.3 런타임 권한 SDK](#213-런타임-권한-sdk)
  - [2.2 날짜/시간 설정](#22-날짜시간-설정)
    - [2.2.1 날짜/시간 설정 SDK](#221-날짜시간-설정-sdk)
    - [2.2.2 시간대 설정 SDK](#222-시간대-설정-sdk)
    - [2.2.3 NTP 설정 SDK](#223-ntp-설정-sdk)
  - [2.3 Wi-Fi 설정](#23-wi-fi-설정)
    - [2.3.1 Captive Portal SDK](#231-captive-portal-sdk)
    - [2.3.2 Open Network Notification SDK](#232-open-network-notification-sdk)
    - [2.3.3 Sleep Policy SDK](#233-sleep-policy-sdk)
    - [2.3.4 Stability SDK](#234-stability-sdk)
    - [2.3.5 국가 코드 SDK](#235-국가-코드-sdk)
    - [2.3.6 주파수 대역 SDK](#236-주파수-대역-sdk)
    - [2.3.7 채널 SDK](#237-채널-sdk)
    - [2.3.8 로밍 SDK](#238-로밍-sdk)
  - [2.4 시스템 설정](#24-시스템-설정)
    - [2.4.1 비행기 모드 SDK](#241-비행기-모드-sdk)
    - [2.4.2 USB 설정 SDK](#242-usb-설정-sdk)
    - [2.4.3 볼륨 SDK](#243-볼륨-sdk)

---

## 1. KeyTool SDK

### 1.1 FN 키 제어 SDK

> **참고:** <br>
> 이 기능은 KeyTool V1.2.6 이상이면서 SL20K 에서만 가능합니다.

#### 개요

이 SDK는 외부 안드로이드 애플리케이션이 KeyToolSL20 애플리케이션과의 브로드캐스트 통신을 통해 FN 키 상태를 제어할 수 있도록 합니다.
FN 키는 비활성화, 활성화 또는 잠금 상태로 설정할 수 있습니다.

##### 빠른 시작

###### 기본 사용법

```java
// FN 키를 활성화 상태로 설정
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE");
intent.putExtra("fn_state", 1);  // 0=비활성화, 1=활성화, 2=잠금

context.sendBroadcast(intent);
```

###### 결과 콜백 사용

```java
// FN 키 상태 변경을 요청하고 결과를 받음
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE");
intent.putExtra("fn_state", 1);
intent.putExtra("fn_control_result_action", "com.example.myapp.FN_CONTROL_RESULT");

context.sendBroadcast(intent);
```

#### API 참조

##### 브로드캐스트 액션

**액션**: `com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE`

##### 파라미터

| 파라미터                       | 타입      | 필수 여부 | 설명                           |
|----------------------------|---------|-------|------------------------------|
| `fn_state`                 | Integer | 예     | FN 키 상태: 0=비활성화, 1=활성화, 2=잠금 |
| `fn_control_result_action` | String  | 아니요   | 결과 콜백 브로드캐스트용 사용자 정의 액션      |

#### FN 키 상태

| 상태값 | 이름        | 설명          |
|-----|-----------|-------------|
| `0` | `DISABLE` | FN 키가 비활성화됨 |
| `1` | `ENABLE`  | FN 키가 활성화됨  |
| `2` | `LOCK`    | FN 키가 잠김    |

#### 결과 콜백

`fn_control_result_action` 파라미터를 제공하면, KeyToolSL20이 결과 브로드캐스트를 전송합니다:

**액션**: 제공한 사용자 정의 액션 문자열 (예: `com.example.myapp.FN_CONTROL_RESULT`)

**결과 파라미터**:

| 파라미터                       | 타입     | 설명                   |
|----------------------------|--------|----------------------|
| `fn_control_result_code`   | int    | 결과 코드 (0=성공, 양수=오류)  |
| `fn_control_error_message` | String | 오류 설명 (오류 발생 시에만 존재) |

##### 결과 코드

| 코드  | 상수                                            | 설명                           |
|-----|-----------------------------------------------|------------------------------|
| `0` | `FN_CONTROL_RESULT_OK`                        | FN 키 상태가 성공적으로 변경됨           |
| `1` | `FN_CONTROL_RESULT_ERROR_SERVICE_CALL`        | PlatformService 호출 중 오류 발생   |
| `2` | `FN_CONTROL_RESULT_ERROR_INVALID_STATE`       | 유효하지 않은 FN 상태값 (0, 1, 2가 아님) |
| `3` | `FN_CONTROL_RESULT_ERROR_SERVICE_BIND_FAILED` | PlatformService 바인딩 실패       |
| `4` | `FN_CONTROL_RESULT_ERROR_TIMEOUT`             | PlatformService 연결 타임아웃      |

#### 전체 예제

##### Java 구현 예시

```java
public class FnControlClient {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public FnControlClient(Context context) {
        this.context = context;
    }

    /**
     * 결과 콜백과 함께 FN 키 상태 설정
     */
    public void setFnState(int state) {
        if (state < 0 || state > 2) {
            throw new IllegalArgumentException("FN 상태는 0, 1, 또는 2여야 합니다");
        }

        // 결과 수신자 등록
        registerResultReceiver();

        // FN 키 상태 변경 브로드캐스트 전송
        Intent intent = new Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE");
        intent.putExtra("fn_state", state);
        intent.putExtra("fn_control_result_action", "com.example.myapp.FN_CONTROL_RESULT");
        context.sendBroadcast(intent);

        String stateName = getStateName(state);
        android.util.Log.i("FnControlClient", "FN 키 상태 변경 요청: state=" + stateName);
    }

    /**
     * 결과 콜백용 브로드캐스트 수신자 등록
     */
    private void registerResultReceiver() {
        if (resultReceiver != null) {
            return; // 이미 등록됨
        }

        resultReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                int resultCode = intent.getIntExtra("fn_control_result_code", -1);
                String errorMessage = intent.getStringExtra("fn_control_error_message");

                if (resultCode == 0) {  // FN_CONTROL_RESULT_OK
                    android.util.Log.i("FnControlClient", "FN 키 상태가 성공적으로 변경됨");
                    onFnStateSetSuccess();
                } else {
                    android.util.Log.e("FnControlClient", "FN 키 상태 변경 실패: " + errorMessage);
                    onFnStateSetFailed(errorMessage);
                }
            }
        };

        android.content.IntentFilter filter = new android.content.IntentFilter("com.example.myapp.FN_CONTROL_RESULT");
        context.registerReceiver(resultReceiver, filter);
    }

    /**
     * 결과 수신자 등록 해제 (onDestroy에서 호출)
     */
    public void cleanup() {
        if (resultReceiver != null) {
            context.unregisterReceiver(resultReceiver);
            resultReceiver = null;
        }
    }

    /**
     * 성공 처리를 위해 오버라이드
     */
    protected void onFnStateSetSuccess() {
        // 성공 처리 (예: 토스트 표시, UI 업데이트)
    }

    /**
     * 실패 처리를 위해 오버라이드
     */
    protected void onFnStateSetFailed(String errorMessage) {
        // 실패 처리 (예: 오류 대화상자 표시)
    }

    private String getStateName(int state) {
        switch (state) {
            case 0: return "DISABLE";
            case 1: return "ENABLE";
            case 2: return "LOCK";
            default: return "UNKNOWN";
        }
    }
}
```

##### Kotlin 구현 예시

```kotlin
class FnControlClient(private val context: Context) {
    private var resultReceiver: BroadcastReceiver? = null

    /**
     * 결과 콜백과 함께 FN 키 상태 설정
     */
    fun setFnState(state: Int) {
        require(state in 0..2) { "FN 상태는 0, 1, 또는 2여야 합니다" }

        // 결과 수신자 등록
        registerResultReceiver()

        // FN 키 상태 변경 브로드캐스트 전송
        val intent = Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE").apply {
            putExtra("fn_state", state)
            putExtra("fn_control_result_action", "com.example.myapp.FN_CONTROL_RESULT")
        }
        context.sendBroadcast(intent)

        val stateName = getStateName(state)
        android.util.Log.i("FnControlClient", "FN 키 상태 변경 요청: state=$stateName")
    }

    /**
     * 결과 콜백용 브로드캐스트 수신자 등록
     */
    private fun registerResultReceiver() {
        if (resultReceiver != null) {
            return // 이미 등록됨
        }

        resultReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val resultCode = intent?.getIntExtra("fn_control_result_code", -1) ?: -1
                val errorMessage = intent?.getStringExtra("fn_control_error_message")

                if (resultCode == 0) {  // FN_CONTROL_RESULT_OK
                    android.util.Log.i("FnControlClient", "FN 키 상태가 성공적으로 변경됨")
                    onFnStateSetSuccess()
                } else {
                    android.util.Log.e("FnControlClient", "FN 키 상태 변경 실패: $errorMessage")
                    onFnStateSetFailed(errorMessage)
                }
            }
        }

        val filter = android.content.IntentFilter("com.example.myapp.FN_CONTROL_RESULT")
        context.registerReceiver(resultReceiver, filter)
    }

    /**
     * 결과 수신자 등록 해제 (onDestroy에서 호출)
     */
    fun cleanup() {
        resultReceiver?.let {
            context.unregisterReceiver(it)
            resultReceiver = null
        }
    }

    /**
     * 성공 처리를 위해 오버라이드
     */
    protected open fun onFnStateSetSuccess() {
        // 성공 처리 (예: 토스트 표시, UI 업데이트)
    }

    /**
     * 실패 처리를 위해 오버라이드
     */
    protected open fun onFnStateSetFailed(errorMessage: String?) {
        // 실패 처리 (예: 오류 대화상자 표시)
    }

    private fun getStateName(state: Int): String = when (state) {
        0 -> "DISABLE"
        1 -> "ENABLE"
        2 -> "LOCK"
        else -> "UNKNOWN"
    }
}
```

##### Activity에서 사용 예시

```java
public class MainActivity extends AppCompatActivity {
    private FnControlClient fnControlClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        fnControlClient = new FnControlClient(this) {
            @Override
            protected void onFnStateSetSuccess() {
                android.widget.Toast.makeText(MainActivity.this,
                        "FN 키 상태가 변경되었습니다", android.widget.Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onFnStateSetFailed(String errorMessage) {
                android.widget.Toast.makeText(MainActivity.this,
                        "실패: " + errorMessage, android.widget.Toast.LENGTH_LONG).show();
            }
        };

        // 예제: FN 키를 활성화로 설정
        findViewById(R.id.btnEnable).setOnClickListener(v -> {
            fnControlClient.setFnState(1);
        });

        // 예제: FN 키를 비활성화로 설정
        findViewById(R.id.btnDisable).setOnClickListener(v -> {
            fnControlClient.setFnState(0);
        });

        // 예제: FN 키를 잠금으로 설정
        findViewById(R.id.btnLock).setOnClickListener(v -> {
            fnControlClient.setFnState(2);
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        fnControlClient.cleanup();
    }
}
```

#### ADB를 이용한 테스트

터미널에서 ADB(Android Debug Bridge) 명령어를 사용하여 FN 키 제어 기능을 테스트할 수 있습니다.

##### FN 키를 활성화로 설정

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 1
```

##### FN 키를 비활성화로 설정

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 0
```

##### FN 키를 잠금으로 설정

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 2
```

##### 결과 콜백으로 테스트

```bash
# 결과를 모니터링할 logcat
adb logcat | grep "FnControlClient"

# 다른 터미널에서 사용자 정의 결과 액션과 함께 FN 키 상태 변경 전송
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE \
    --ei fn_state 1 \
    --es fn_control_result_action "com.example.myapp.FN_CONTROL_RESULT"
```

##### 유효하지 않은 상태값 테스트 (오류 경우)

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 5
```

#### 오류 처리

##### 유효하지 않은 FN 상태값

**오류 메시지**: `"Invalid FN state: 5. Must be 0, 1, or 2."`

**결과 코드**: `FN_CONTROL_RESULT_ERROR_INVALID_STATE` (2)

**해결책**: 유효한 FN 상태값(0, 1, 또는 2)을 입력했는지 확인하세요.

##### 서비스 바인딩 실패

**오류 메시지**: `"Failed to bind to PlatformService"`

**결과 코드**: `FN_CONTROL_RESULT_ERROR_SERVICE_BIND_FAILED` (3)

**해결책**:
- KeyToolSL20 앱이 설치되어 있고 실행 중인지 확인
- 기기에 시스템 권한(sharedUserId)이 있는지 확인
- 매니페스트에 권한 관련 문제가 없는지 확인

##### 서비스 호출 오류

**오류 메시지**: `"RemoteException: [오류 세부 정보]"`

**결과 코드**: `FN_CONTROL_RESULT_ERROR_SERVICE_CALL` (1)

**해결책**: logcat에서 자세한 오류 정보를 확인하고 시스템 상태를 확인하세요.

##### 연결 타임아웃

**오류 메시지**: `"PlatformService connection timeout"`

**결과 코드**: `FN_CONTROL_RESULT_ERROR_TIMEOUT` (4)

**해결책**:
- PlatformService가 실행 중인지 확인
- 기기 성능 및 시스템 부하 확인
- 잠시 후 작업을 다시 시도

#### 상수 참조

##### FnControlReceiver의 공개 상수

```kotlin
// 브로드캐스트 액션
const val ACTION_CONTROL_FN_STATE = "com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE"

// 결과 코드
const val FN_CONTROL_RESULT_OK = 0
const val FN_CONTROL_RESULT_CANCELED = -1
const val FN_CONTROL_RESULT_ERROR_SERVICE_CALL = 1
const val FN_CONTROL_RESULT_ERROR_INVALID_STATE = 2
const val FN_CONTROL_RESULT_ERROR_SERVICE_BIND_FAILED = 3
const val FN_CONTROL_RESULT_ERROR_TIMEOUT = 4

// 결과 메시지 키
const val FN_CONTROL_EXTRA_ERROR_MESSAGE = "fn_control_error_message"
```

---

### 1.2 키 설정 SDK

> **참고:** <br>
> 이 기능은 KeyTool V1.2.6 이상이면서 SL20, SL20P, SL20K 에서만 가능합니다.

#### 개요

이 SDK는 외부 안드로이드 애플리케이션이 KeyToolSL20 애플리케이션과의 브로드캐스트 통신을 통해 물리 키의 기능을 리매핑할 수 있도록 합니다.
외부 앱은 임의의 물리 키에 할당된 함수를 변경하고 해당 키의 Wake-up 기능을 활성화 또는 비활성화할 수 있습니다.

##### 빠른 시작

###### 기본 사용법

```java
// 물리 키를 새로운 함수로 리매핑
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Left Scan");  // 리매핑할 키
intent.putExtra("key_function", "Scan");    // 새로운 함수
intent.putExtra("key_wakeup", false);       // Wake-up 활성화 여부

context.sendBroadcast(intent);
```

###### Wakeup만 제어

```java
// 왼쪽 스캔 키의 Wakeup만 활성화 (function 변경 안 함)
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Right Scan");
intent.putExtra("key_wakeup", true);

context.sendBroadcast(intent);
```

###### Function만 제어

```java
// 왼쪽 스캔 키의 함수만 변경 (wakeup 설정 안 함)
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Left Scan");
intent.putExtra("key_function", "Scan");

context.sendBroadcast(intent);
```

###### Function과 Wakeup 함께 제어

```java
// 키를 리매핑하고 결과를 받음
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Left Scan");
intent.putExtra("key_function", "com.example.myapp");
intent.putExtra("key_wakeup", true);
intent.putExtra("key_setting_result_action", "com.example.myapp.KEY_SETTING_RESULT");

context.sendBroadcast(intent);
```

#### API 참조

##### 브로드캐스트 액션

**액션**: `com.m3.keytoolsl20.ACTION_SET_KEY`

##### 파라미터

| 파라미터                        | 타입      | 필수 여부 | 설명                                       |
|-----------------------------|---------|-------|------------------------------------------|
| `key_title`                 | String  | 예     | 리매핑할 키 이름 (예: "Left Scan")               |
| `key_function`              | String  | 아니요   | 새로 할당할 함수 (예: "Scan", "com.example.app") |
| `key_wakeup`                | boolean | 아니요   | 이 키의 Wake-up 활성화/비활성화                    |
| `key_setting_result_action` | String  | 아니요   | 결과 콜백 브로드캐스트용 사용자 정의 액션                  |

**주의**: `key_function`과 `key_wakeup` 중 **최소 하나는 제공되어야 합니다**. (둘 다 생략 불가)

#### 지원 키 및 할당 가능한 함수

사용 가능한 키와 할당 가능한 함수는 기기 모델에 따라 다릅니다.

##### SL20

###### 지원 키
- `"Left Scan"` - 왼쪽 스캔 버튼
- `"Right Scan"` - 오른쪽 스캔 버튼 (사용 가능한 경우)
- `"Volume Up"` - 볼륨 업 키
- `"Volume Down"` - 볼륨 다운 키
- `"Back"` - 뒤로 버튼
- `"Home"` - 홈 버튼
- `"Recent"` - 최근 앱 버튼
- `"Camera"` - 카메라 버튼

###### 할당 가능한 함수
- **시스템 함수**: `"Default"`, `"Disable"`, `"Scan"`, `"Volume up"`, `"Volume down"`, `"Back"`, `"Home"`, `"Menu"`, `"Camera"`
- **특수 기능**: `"★"`
- **커스텀 앱**: 패키지 이름 (예: `"com.example.myapp"`)

##### SL20P

###### 지원 키
- `"Left Scan"`, `"Right Scan"`, `"Volume Up"`, `"Volume Down"`, `"Back"`, `"Home"`, `"Recent"`, `"Camera"`

###### 할당 가능한 함수
- **시스템 함수**: `"Default"`, `"Disable"`, `"Scan"`, `"Volume up"`, `"Volume down"`, `"Back"`, `"Home"`, `"Menu"`, `"Camera"`
- **특수 기능**: `"★"`
- **커스텀 앱**: 패키지 이름 (예: `"com.example.myapp"`)
- **키보드 입력**:
  - **기능 키**: `"F1"` ~ `"F12"`
  - **탐색 키**: `"↑"`, `"↓"`, `"←"`, `"→"`, `"Enter"`, `"Tab"`, `"Space"`, `"Del"`, `"ESC"`, `"Search"`
  - **문자 및 숫자**: `"A"`-`"Z"`, `"a"`-`"z"`, `"0"`-`"9"`
  - **특수 문자**: `"`!`, `"@"`, `"#"` 등 (`"£"`, `"€"`, `"¥"`, `"₩"` 포함)

##### SL20K

###### 지원 키
- **스캔 및 물리 버튼**: `"Left Scan"`, `"Right Scan"`, `"Volume Up"`, `"Volume Down"`, `"Back"`, `"Home"`, `"Recent"`, `"Camera"`, `"Front Scan"`
- **탐색 및 기능 키**: `"←"`, `"↑"`, `"↓"`, `"→"`, `"Enter"`, `"Esc"`, `"Tab"`, `"Shift"`, `"Delete"`, `"Alt"`, `"Ctrl"`, `"Fn"`
- **기능 키**: `"F1"` ~ `"F8"`
- **문자 및 숫자**: `"A"`-`"Z"`, `"0"`-`"9"`
- **특수 문자**: `"."`, `"★"`

###### 할당 가능한 함수
- SL20P와 동일한 모든 함수를 지원합니다.

##### WD10

- 현재 개발 중입니다.

#### 결과 콜백

`key_setting_result_action` 파라미터를 제공하면, KeyToolSL20이 결과 브로드캐스트를 전송합니다:

**액션**: 제공한 사용자 정의 액션 문자열 (예: `com.example.myapp.KEY_SETTING_RESULT`)

**결과 파라미터**:

| 파라미터                        | 타입     | 설명                   |
|-----------------------------|--------|----------------------|
| `key_setting_result_code`   | int    | 결과 코드 (0=성공, 양수=오류)  |
| `key_setting_error_message` | String | 오류 설명 (오류 발생 시에만 존재) |

##### 결과 코드

| 코드  | 상수                                       | 설명            |
|-----|------------------------------------------|---------------|
| `0` | `KEY_SETTING_RESULT_OK`                  | 키 설정 성공       |
| `1` | `KEY_SETTING_RESULT_ERROR_INVALID_KEY`   | 키 이름을 찾을 수 없음 |
| `2` | `KEY_SETTING_RESULT_ERROR_FILE_WRITE`    | 파일 저장 실패      |
| `3` | `KEY_SETTING_RESULT_ERROR_MISSING_PARAM` | 필수 파라미터 누락    |

#### 전체 예제

##### Java 구현 예시

```java
public class KeySettingClient {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public KeySettingClient(Context context) {
        this.context = context;
    }

    /**
     * 결과 콜백과 함께 키 매핑 설정
     */
    public void setKeyMapping(String keyTitle, String keyFunction, boolean enableWakeup) {
        if (keyTitle == null || keyTitle.isEmpty() || keyFunction == null || keyFunction.isEmpty()) {
            throw new IllegalArgumentException("키 이름과 함수는 비워 둘 수 없습니다");
        }

        // 결과 수신자 등록
        registerResultReceiver();

        // 키 설정 브로드캐스트 전송
        Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
        intent.putExtra("key_title", keyTitle);
        intent.putExtra("key_function", keyFunction);
        intent.putExtra("key_wakeup", enableWakeup);
        intent.putExtra("key_setting_result_action", "com.example.myapp.KEY_SETTING_RESULT");
        context.sendBroadcast(intent);

        android.util.Log.i("KeySettingClient", "키 매핑 요청 전송: title=" + keyTitle + ", function=" + keyFunction);
    }

    /**
     * 결과 콜백용 브로드캐스트 수신자 등록
     */
    private void registerResultReceiver() {
        if (resultReceiver != null) {
            return; // 이미 등록됨
        }

        resultReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                int resultCode = intent.getIntExtra("key_setting_result_code", -1);
                String errorMessage = intent.getStringExtra("key_setting_error_message");

                if (resultCode == 0) {  // KEY_SETTING_RESULT_OK
                    android.util.Log.i("KeySettingClient", "키 매핑이 성공적으로 변경됨");
                    onKeyMappingSuccess();
                } else {
                    android.util.Log.e("KeySettingClient", "키 매핑 변경 실패: " + errorMessage);
                    onKeyMappingFailed(errorMessage);
                }
            }
        };

        android.content.IntentFilter filter = new android.content.IntentFilter("com.example.myapp.KEY_SETTING_RESULT");
        context.registerReceiver(resultReceiver, filter);
    }

    /**
     * 결과 수신자 등록 해제 (onDestroy에서 호출)
     */
    public void cleanup() {
        if (resultReceiver != null) {
            context.unregisterReceiver(resultReceiver);
            resultReceiver = null;
        }
    }

    /**
     * 성공 처리를 위해 오버라이드
     */
    protected void onKeyMappingSuccess() {
        // 성공 처리 (예: 토스트 표시, UI 업데이트)
    }

    /**
     * 실패 처리를 위해 오버라이드
     */
    protected void onKeyMappingFailed(String errorMessage) {
        // 실패 처리 (예: 오류 대화상자 표시)
    }
}
```

##### Kotlin 구현 예시

```kotlin
class KeySettingClient(private val context: Context) {
    private var resultReceiver: BroadcastReceiver? = null

    /**
     * 결과 콜백과 함께 키 매핑 설정
     */
    fun setKeyMapping(keyTitle: String, keyFunction: String, enableWakeup: Boolean) {
        require(keyTitle.isNotEmpty()) { "키 이름은 비워 둘 수 없습니다" }
        require(keyFunction.isNotEmpty()) { "키 함수는 비워 둘 수 없습니다" }

        // 결과 수신자 등록
        registerResultReceiver()

        // 키 설정 브로드캐스트 전송
        val intent = Intent("com.m3.keytoolsl20.ACTION_SET_KEY").apply {
            putExtra("key_title", keyTitle)
            putExtra("key_function", keyFunction)
            putExtra("key_wakeup", enableWakeup)
            putExtra("key_setting_result_action", "com.example.myapp.KEY_SETTING_RESULT")
        }
        context.sendBroadcast(intent)

        android.util.Log.i("KeySettingClient", "키 매핑 요청 전송: title=$keyTitle, function=$keyFunction")
    }

    /**
     * 결과 콜백용 브로드캐스트 수신자 등록
     */
    private fun registerResultReceiver() {
        if (resultReceiver != null) {
            return // 이미 등록됨
        }

        resultReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val resultCode = intent?.getIntExtra("key_setting_result_code", -1) ?: -1
                val errorMessage = intent?.getStringExtra("key_setting_error_message")

                if (resultCode == 0) {  // KEY_SETTING_RESULT_OK
                    android.util.Log.i("KeySettingClient", "키 매핑이 성공적으로 변경됨")
                    onKeyMappingSuccess()
                } else {
                    android.util.Log.e("KeySettingClient", "키 매핑 변경 실패: $errorMessage")
                    onKeyMappingFailed(errorMessage)
                }
            }
        }

        val filter = android.content.IntentFilter("com.example.myapp.KEY_SETTING_RESULT")
        context.registerReceiver(resultReceiver, filter)
    }

    /**
     * 결과 수신자 등록 해제 (onDestroy에서 호출)
     */
    fun cleanup() {
        resultReceiver?.let {
            context.unregisterReceiver(it)
            resultReceiver = null
        }
    }

    /**
     * 성공 처리를 위해 오버라이드
     */
    protected open fun onKeyMappingSuccess() {
        // 성공 처리 (예: 토스트 표시, UI 업데이트)
    }

    /**
     * 실패 처리를 위해 오버라이드
     */
    protected open fun onKeyMappingFailed(errorMessage: String?) {
        // 실패 처리 (예: 오류 대화상자 표시)
    }
}
```

##### Activity에서 사용 예시

```java
public class MainActivity extends AppCompatActivity {
    private KeySettingClient keySettingClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        keySettingClient = new KeySettingClient(this) {
            @Override
            protected void onKeyMappingSuccess() {
                android.widget.Toast.makeText(MainActivity.this,
                        "키 매핑이 성공적으로 변경되었습니다", android.widget.Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onKeyMappingFailed(String errorMessage) {
                android.widget.Toast.makeText(MainActivity.this,
                        "실패: " + errorMessage, android.widget.Toast.LENGTH_LONG).show();
            }
        };

        // 예제: 왼쪽 스캔 키를 카메라 함수로 리매핑
        findViewById(R.id.btnRemapToCamera).setOnClickListener(v -> {
            keySettingClient.setKeyMapping("Left Scan", "Camera", false);
        });

        // 예제: 왼쪽 스캔 키를 커스텀 앱으로 리매핑
        findViewById(R.id.btnRemapToApp).setOnClickListener(v -> {
            keySettingClient.setKeyMapping("Left Scan", "com.example.myapp", true);
        });

        // 예제: 왼쪽 스캔 키를 F1로 리매핑
        findViewById(R.id.btnRemapToF1).setOnClickListener(v -> {
            keySettingClient.setKeyMapping("Left Scan", "F1", false);
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        keySettingClient.cleanup();
    }
}
```

#### ADB를 이용한 테스트

터미널에서 ADB(Android Debug Bridge) 명령어를 사용하여 키 설정 기능을 테스트할 수 있습니다.

##### Wakeup만 제어

```bash
# 왼쪽 스캔 키의 Wakeup 활성화
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --ez key_wakeup true

# 오른쪽 스캔 키의 Wakeup 비활성화
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Right Scan'" --ez key_wakeup false
```

##### Function만 제어

```bash
# 왼쪽 스캔 키의 함수를 Scan으로 변경
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Scan'"

# 왼쪽 스캔 키의 함수를 Volume up으로 변경
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Volume up'"

# 여러 키를 다른 함수로 변경
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Up'" --es key_function "'Back'"
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Down'" --es key_function "'Disable'"
```

##### Function과 Wakeup 함께 제어

```bash
# 키를 시스템 함수로 리매핑하면서 Wakeup 설정
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Volume up'" --ez key_wakeup true
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Up'" --es key_function "'Scan'" --ez key_wakeup false
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Down'" --es key_function "'Disable'" --ez key_wakeup true
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Right Scan'" --es key_function "'Default'" --ez key_wakeup false
```

##### 커스텀 앱으로 함수 변경

```bash
# 키를 커스텀 앱으로 리매핑
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'com.example.myapplication'"

# 커스텀 앱으로 리매핑하면서 Wakeup 활성화
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'com.example.myapplication'" --ez key_wakeup true
```

##### 키보드 입력으로 함수 변경

```bash
# 키를 키보드 함수로 변경
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'F1'"

# 키를 키보드 함수로 변경하면서 Wakeup 설정
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'F1'" --ez key_wakeup false
```

##### 결과 콜백으로 테스트

```bash
# 결과를 모니터링할 logcat
adb logcat | Select-string "KeySettingClient"
# 혹은 adb logcat | grep "KeySettingClient"

# 다른 터미널에서 사용자 정의 결과 액션과 함께 키 설정 전송
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Scan'" --ez key_wakeup true --es key_setting_result_action "com.example.myapp.KEY_SETTING_RESULT"

# Wakeup만 제어하면서 결과 콜백 받기
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Right Scan'" --ez key_wakeup true --es key_setting_result_action "com.example.myapp.KEY_SETTING_RESULT"
```

##### 유효하지 않은 파라미터 테스트 (오류 경우)

```bash
# 유효하지 않은 키 이름
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'InvalidKey'" --es key_function "'Scan'"

# 둘 다 생략 (오류 - 최소 하나는 제공되어야 함)
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'"

# key_title 누락 (오류 - 필수 파라미터)
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_function "'Scan'"
```

#### 오류 처리

##### key_title 누락

**오류 메시지**: `"Required parameter is missing: key_title"`

**결과 코드**: `KEY_SETTING_RESULT_ERROR_MISSING_PARAM` (3)

**해결책**: 인텐트에 `key_title` 파라미터를 반드시 포함하세요.

##### key_function과 key_wakeup 모두 누락

**오류 메시지**: `"Both key_function and key_wakeup are missing. At least one is required."`

**결과 코드**: `KEY_SETTING_RESULT_ERROR_MISSING_PARAM` (3)

**해결책**: `key_function` 또는 `key_wakeup` 중 최소 하나를 포함하세요.

##### 유효하지 않은 키 이름

**오류 메시지**: `"Key not found: InvalidKeyName"`

**결과 코드**: `KEY_SETTING_RESULT_ERROR_INVALID_KEY` (1)

**해결책**: 지원 키 목록에서 유효한 키 이름을 사용하세요.

##### 파일 저장 실패

**오류 메시지**: `"Failed to save key settings: [오류 세부 정보]"`

**결과 코드**: `KEY_SETTING_RESULT_ERROR_FILE_WRITE` (2)

**해결책**:
- 기기의 저장 공간 확인
- 파일 시스템 권한 확인
- KeyToolSL20 앱이 구성 파일에 쓰기 권한이 있는지 확인

#### 상수 참조

##### KeySettingReceiver의 공개 상수

```kotlin
// 브로드캐스트 액션
const val ACTION_SET_KEY = "com.m3.keytoolsl20.ACTION_SET_KEY"

// 결과 코드
const val KEY_SETTING_RESULT_OK = 0
const val KEY_SETTING_RESULT_ERROR_INVALID_KEY = 1
const val KEY_SETTING_RESULT_ERROR_FILE_WRITE = 2
const val KEY_SETTING_RESULT_ERROR_MISSING_PARAM = 3

// 결과 메시지 키
const val KEY_SETTING_EXTRA_ERROR_MESSAGE = "key_setting_error_message"
```

---

## 2. Startup SDK

### 2.1 앱 관리

#### 2.1.1 APK 설치 SDK

> **참고** <br>
>
> Startup 5.3.4 버전부터 지원합니다.

##### 개요

이 SDK는 외부 애플리케이션이 브로드캐스트 인텐트를 통해 디바이스에 APK 파일을 설치할 수 있게 해주는 API입니다.
로컬 파일 경로 또는 URL에서 APK를 다운로드하여 설치하는 두 가지 방식을 지원합니다.

###### 빠른 시작

**기본 사용법 (로컬 파일)**

```kotlin
// 로컬 파일에서 APK 설치
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 0)  // 로컬 파일
    putExtra("path", "/sdcard/downloads/myapp.apk")
}
context.sendBroadcast(intent)
```

**기본 사용법 (URL)**

```kotlin
// URL에서 APK 다운로드 및 설치
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 1)  // URL 다운로드
    putExtra("url", "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk")
}
context.sendBroadcast(intent)
```

##### API 참조

###### 브로드캐스트 액션

**액션**: `com.android.server.startupservice.system`

###### 파라미터

| 파라미터      | 타입     | 필수 여부          | 설명                                                                                                          |
|-----------|--------|----------------|-------------------------------------------------------------------------------------------------------------|
| `setting` | String | 필수             | 설정 타입. APK 설치의 경우 `"apk_install"` 값 사용                                                                      |
| `type`    | int    | 필수             | 설치 방식. `0`: 로컬 파일, `1`: URL 다운로드                                                                            |
| `path`    | String | `type=0`일 때 필수 | APK 파일의 절대 경로 (예: `/sdcard/downloads/myapp.apk`)                                                            |
| `url`     | String | `type=1`일 때 필수 | APK 다운로드 URL (예: `https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk`) |

##### 전체 예제

###### 로컬 파일 설치

**Kotlin 예시:**

```kotlin
// 로컬 파일에서 APK 설치
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 0)  // 로컬 파일
    putExtra("path", "/sdcard/downloads/myapp.apk")
}
context.sendBroadcast(intent)
```

**Java 예시:**
```java
// 로컬 파일에서 APK 설치
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "apk_install");
intent.putExtra("type", 0);  // 로컬 파일
intent.putExtra("path", "/sdcard/downloads/myapp.apk");
context.sendBroadcast(intent);
```

###### URL에서 다운로드 및 설치

**Kotlin 예시:**

```kotlin
// URL에서 APK 다운로드 및 설치
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 1)  // URL 다운로드
    putExtra("url", "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk")
}
context.sendBroadcast(intent)
```

**Java 예시:**

```java
// URL에서 APK 다운로드 및 설치
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "apk_install");
intent.putExtra("type", 1);  // URL 다운로드
intent.putExtra("url", "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk");
context.sendBroadcast(intent);
```

##### ADB를 사용한 테스트

###### 로컬 파일 설치

```bash
# 로컬 파일에서 APK 설치
adb shell am broadcast -a com.android.server.startupservice.system --es setting "apk_install" --ei type 0 --es path "/sdcard/downloads/myapp.apk"
```

###### URL에서 다운로드 및 설치

```bash
# URL에서 APK 다운로드 및 설치
adb shell am broadcast -a com.android.server.startupservice.system --es setting "apk_install" --ei type 1 --es url "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk"
```

##### 주의사항

- URL에서 다운로드 시, APK는 `/data/downloads/` 디렉토리에 저장됩니다.
- URL 설치는 네트워크 연결이 필요합니다.
- 다운로드 진행 상황은 브로드캐스트로 모니터링할 수 있습니다 (`android.app.DownloadManager.ACTION_DOWNLOAD_COMPLETE`).
- APK 설치 후 즉시 관련 앱을 활성화하거나 권한을 설정하려고 하면 타이밍 이슈가 발생할 수 있습니다. 설치 완료를 확인한 후 다음 작업을 진행해야 합니다.


##### 문제 해결

APK 설치 실패 시 다음을 확인하십시오.

```bash
# 1. 로그 확인
adb logcat | grep -i "apk\|install"

# 2. 파일 존재 확인
adb shell ls -la /data/downloads/myapp.apk

# 3. 파일 권한 확인
adb shell stat /data/downloads/myapp.apk

# 4. APK 무결성 확인
adb shell md5sum /data/downloads/myapp.apk
```

---

#### 2.1.2 앱 활성화/비활성화 SDK

> **참고** <br>
>
> StartUp 6.2.21 버전부터 지원됩니다.

##### 개요

이 SDK는 외부 애플리케이션이 브로드캐스트 인텐트를 통해 설치된 앱을 활성화하거나 비활성화할 수 있도록 지원합니다.
비활성화된 앱은 실행할 수 없으며 시스템 리소스를 사용하지 않습니다.

###### 빠른 시작

**앱 활성화**

```kotlin
// 앱 활성화
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.google.android.gms")
    putExtra("enable", true)
}
context.sendBroadcast(intent)
```

**앱 비활성화**

```kotlin
// 앱 비활성화
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.example.unwantedapp")
    putExtra("enable", false)
}
context.sendBroadcast(intent)
```

##### API 참조

###### 브로드캐스트 액션

**액션**: `com.android.server.startupservice.system`

###### 파라미터

| 파라미터           | 타입      | 필수 여부 | 설명                                   |
|----------------|---------|-------|--------------------------------------|
| `setting`      | String  | 예     | 설정 타입. 앱 제어의 경우 `"application"` 값 사용 |
| `package_name` | String  | 예     | 대상 앱의 패키지명 (예: `com.example.myapp`)  |
| `enable`       | boolean | 예     | `true`이면 활성화, `false`이면 비활성화         |

##### 전체 예제

###### 앱 활성화

**Kotlin 예시:**

```kotlin
// 앱 활성화
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.google.android.calculator")
    putExtra("enable", true)
}
context.sendBroadcast(intent)
```

**Java 예시:**

```java
// 앱 활성화
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "application");
intent.putExtra("package_name", "com.google.android.calculator");
intent.putExtra("enable", true);
context.sendBroadcast(intent);
```

###### 앱 비활성화

**Kotlin 예시:**

```kotlin
// 앱 비활성화
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.google.android.calculator")
    putExtra("enable", false)
}
context.sendBroadcast(intent)
```

**Java 예시:**

```java
// 앱 비활성화
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "application");
intent.putExtra("package_name", "com.google.android.calculator");
intent.putExtra("enable", false);
context.sendBroadcast(intent);
```

##### ADB를 사용한 테스트

###### 앱 활성화

```bash
# 앱 활성화
adb shell am broadcast -a com.android.server.startupservice.system --es setting "application" --es package_name "com.google.android.calculator" --ez enable true
```

###### 앱 비활성화

```bash
# 앱 비활성화
adb shell am broadcast -a com.android.server.startupservice.system --es setting "application" --es package_name "com.google.android.calculator" --ez enable false
```

##### 주의사항

- 시스템 앱도 비활성화할 수 있으나, 시스템 안정성에 영향을 줄 수 있어 주의가 필요합니다.
- 비활성화된 앱은 백그라운드에서 실행되지 않으며 알림을 보내지 않습니다.
- 비활성화된 앱을 다시 활성화하려면 `enable: true`로 브로드캐스트를 다시 전송하면 됩니다.


##### 문제 해결

앱 비활성화 후 문제가 발생하면 다음을 확인하십시오.

```bash
# 1. 비활성화된 앱 목록 확인
adb shell pm list packages -d

# 2. 앱 다시 활성화
adb shell pm enable com.example.app

# 3. 앱 강제 정지 후 활성화
adb shell am force-stop com.example.app
adb shell pm enable com.example.app
```

---

#### 2.1.3 런타임 권한 SDK

> **참고** <br>
> **지원 기기**: Android 6.0 (API 23) 이상
> StartUp 앱 버전 6.4.17 부터 지원합니다.

##### 개요

이 SDK는 외부 애플리케이션이 브로드캐스트 인텐트를 통해 다른 앱의 위험 권한(Dangerous Permissions)을 부여하거나 취소할 수 있도록 지원합니다.
이 기능은 사용자 상호작용 없이 권한을 제어해야 하는 시나리오에서 유용합니다.

###### 빠른 시작

**권한 부여**

```kotlin
// 카메라 권한 부여
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 1)  // 허용
}
context.sendBroadcast(intent)
```

**권한 거부**

```kotlin
// 카메라 권한 거부
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 2)  // 거부 (중요: 2를 사용해야 함)
}
context.sendBroadcast(intent)
```

##### API 참조

###### 브로드캐스트 액션

**액션**: `com.android.server.startupservice.system`

###### 파라미터

| 파라미터              | 타입     | 필수 여부 | 설명                                   |
|-------------------|--------|-------|--------------------------------------|
| `setting`         | String | 예     | 설정 타입. 권한 제어의 경우 `"permission"` 값 사용 |
| `package`         | String | 예     | 대상 앱의 패키지명                           |
| `permission`      | String | 예     | 권한명 (예: `android.permission.CAMERA`) |
| `permission_mode` | int    | 예     | `1`=허용, `2`=거부                       |

**permission_mode 값 상세 설명**:
- **1 (GRANT)**: 권한 허용. 앱이 해당 권한을 사용할 수 있습니다.
- **2 (DENY)**: 권한 거부. 앱이 해당 권한을 사용할 수 없습니다.

###### 지원하는 위험 권한 목록

이 SDK는 **Android의 모든 위험 권한(Dangerous Permissions)**을 지원합니다. 주요 권한 목록:

- **카메라**: `android.permission.CAMERA`
- **위치**: `android.permission.ACCESS_FINE_LOCATION`, `android.permission.ACCESS_COARSE_LOCATION`
- **연락처**: `android.permission.READ_CONTACTS`, `android.permission.WRITE_CONTACTS`
- **전화**: `android.permission.CALL_PHONE`, `android.permission.READ_CALL_LOG`, `android.permission.WRITE_CALL_LOG`, `android.permission.READ_PHONE_STATE`
- **마이크**: `android.permission.RECORD_AUDIO`
- **파일/미디어** (Android 12 이하): `android.permission.READ_EXTERNAL_STORAGE`, `android.permission.WRITE_EXTERNAL_STORAGE`
- **미디어** (Android 13+): `android.permission.READ_MEDIA_IMAGES`, `android.permission.READ_MEDIA_VIDEO`, `android.permission.READ_MEDIA_AUDIO`
- **달력**: `android.permission.READ_CALENDAR`, `android.permission.WRITE_CALENDAR`
- **문자/SMS**: `android.permission.READ_SMS`, `android.permission.SEND_SMS`
- **센서**: `android.permission.BODY_SENSORS`
- **알림** (Android 13+): `android.permission.POST_NOTIFICATIONS`
- **기타**: `android.permission.ACCESS_MEDIA_LOCATION`

###### 제약사항

다음과 같은 경우 권한 제어가 **불가능**합니다:

1. **앱이 권한을 선언하지 않은 경우**: 대상 앱의 AndroidManifest.xml에 해당 권한이 선언되어 있어야 합니다.
2. **시스템 고정 권한**: `SYSTEM_FIXED` 또는 `POLICY_FIXED` 플래그가 설정된 권한은 변경할 수 없습니다.
   - 예: 시스템 카메라 앱의 CAMERA 권한, 기본 전화 앱의 CALL_PHONE 권한
3. **설치 시 권한**: 일반 권한(Normal Permissions)은 런타임 제어 대상이 아닙니다.

**권한 플래그 확인 방법**:
```bash
adb shell dumpsys package [패키지명] | findstr "[권한명]"
```

출력 예시:
```
android.permission.CAMERA: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT ]
```
위 경우 `SYSTEM_FIXED` 플래그로 인해 제어가 불가능합니다.

##### 전체 예제

###### 권한 부여

**Kotlin 예시:**

```kotlin
// 카메라 권한 부여
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 1)  // 허용
}
context.sendBroadcast(intent)
```

**Java 예시:**

```java
// 카메라 권한 부여
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "permission");
intent.putExtra("package", "com.example.cameraapp");
intent.putExtra("permission", "android.permission.CAMERA");
intent.putExtra("permission_mode", 1);  // 허용
context.sendBroadcast(intent);
```

###### 권한 거부

**Kotlin 예시:**

```kotlin
// 카메라 권한 거부
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 2)  // 거부 (중요: 2를 사용해야 함)
}
context.sendBroadcast(intent)
```

**Java 예시:**

```java
// 카메라 권한 거부
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "permission");
intent.putExtra("package", "com.example.cameraapp");
intent.putExtra("permission", "android.permission.CAMERA");
intent.putExtra("permission_mode", 2);  // 거부 (중요: 2를 사용해야 함)
context.sendBroadcast(intent);
```

###### 배치 권한 제어

여러 권한을 동시에 제어하려면 각 권한에 대해 별도의 브로드캐스트를 전송합니다.

```kotlin
// 여러 권한을 한 번에 부여
fun grantMultiplePermissions(
    context: Context,
    packageName: String,
    permissions: List<String>
) {
    permissions.forEach { permission ->
        val intent = Intent("com.android.server.startupservice.system").apply {
            putExtra("setting", "permission")
            putExtra("package", packageName)
            putExtra("permission", permission)
            putExtra("permission_mode", 1)  // 허용
        }
        context.sendBroadcast(intent)
    }
}

// 사용 예시
grantMultiplePermissions(
    context,
    "com.example.app",
    listOf(
        "android.permission.CAMERA",
        "android.permission.RECORD_AUDIO",
        "android.permission.ACCESS_FINE_LOCATION"
    )
)
```

##### ADB를 사용한 테스트

###### 권한 부여

```bash
# Youtube 에 마이크 사용 권한 부여
adb shell am broadcast -a com.android.server.startupservice.system --es setting "permission" --es package "com.google.android.youtube" --es permission "android.permission.RECORD_AUDIO" --ei permission_mode 1
```

###### 권한 거부

```bash
# Youtube 에 마이크 사용 권한 거부
adb shell am broadcast -a com.android.server.startupservice.system --es setting "permission" --es package "com.google.android.youtube" --es permission "android.permission.RECORD_AUDIO" --ei permission_mode 2
```

###### 권한 상태 확인

```bash
# 특정 권한 상태 확인 (Windows)
adb shell dumpsys package com.google.android.youtube | findstr "RECORD_AUDIO"

# 출력 예시:
# android.permission.RECORD_AUDIO: granted=true, flags=[ POLICY_FIXED|USER_SENSITIVE_WHEN_GRANTED ]
```

```bash
# 모든 런타임 권한 확인 (Windows)
adb shell dumpsys package com.google.android.youtube | findstr "granted"

```

##### 문제 해결

###### 권한 변경이 적용되지 않는 경우

**1. 앱이 권한을 선언했는지 확인**

```bash
# Windows에서 권한 확인
adb shell dumpsys package com.example.app | findstr "android.permission.CAMERA"

# 출력이 없으면 앱이 해당 권한을 선언하지 않은 것
```

**2. 권한 플래그 확인**

```bash
adb shell dumpsys package com.example.app | findstr "CAMERA"

# 출력 예시:
# android.permission.CAMERA: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT ]
```

- `SYSTEM_FIXED` 또는 `POLICY_FIXED` 플래그가 있으면 제어 불가
- 시스템 앱이나 기본 앱의 핵심 권한에 주로 설정됨

**3. permission_mode 값이 올바른지 확인**

```bash
# 잘못된 예 (거부하려는데 0 사용)
--ei permission_mode 0  # 기본값으로 복원 (거부가 아님!)

# 올바른 예 (거부)
--ei permission_mode 2  # 명시적 거부
```

**4. 시스템 권한 목록 확인**

```bash
# 모든 위험 권한 그룹 확인
adb shell pm list permissions -g -d

# 특정 앱이 요청하는 권한 확인
adb shell dumpsys package com.example.app | findstr "requested permissions"
```

###### 일반적인 오류 상황

| 증상                               | 원인                                  | 해결 방법                       |
|----------------------------------|-------------------------------------|-----------------------------|
| 로그에 `result: true`인데 권한이 변경되지 않음 | `permission_mode=0` 사용 (기본값 복원)     | `permission_mode=2` 사용 (거부) |
| 권한이 앱 권한 목록에 없음                  | 앱이 AndroidManifest.xml에 권한을 선언하지 않음 | 권한을 선언한 다른 앱으로 테스트          |
| `SYSTEM_FIXED` 플래그               | 시스템 앱의 핵심 권한                        | 제어 불가, 다른 앱으로 테스트           |
| 권한은 변경되는데 앱 동작이 안 바뀜             | 앱이 권한 캐시를 사용                        | 앱 강제 종료 후 재시작               |

---

### 2.2 날짜/시간 설정

#### 2.2.1 날짜/시간 설정 SDK

> **참고** <br>
> 이 기능은 StartUp 버전 5.3.4부터 지원됩니다.

##### 개요

이 SDK는 외부 안드로이드 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 날짜와 시간을 수동으로 설정할 수 있도록 합니다.

###### 빠른 시작

**기본 사용법**

```java
// Set date and time manually
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "datetime");
intent.putExtra("date", "2025-01-15");
intent.putExtra("time", "14:30:00");
context.sendBroadcast(intent);
```

**결과 콜백 사용**

```java
// Send datetime setting and receive result
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "datetime");
intent.putExtra("date", "2025-01-15");
intent.putExtra("time", "14:30:00");
// The value for "datetime_result_action" (e.g., "com.example.myapp.DATETIME_RESULT") can be any custom string you want.
intent.putExtra("datetime_result_action", "com.example.myapp.DATETIME_RESULT");
context.sendBroadcast(intent);
```

##### API 참조

###### 브로드캐스트 액션

**액션**: `com.android.server.startupservice.system`

###### 파라미터

| 파라미터                      | 타입     | 필수 여부 | 설명                                                  |
|---------------------------|--------|-------|-----------------------------------------------------|
| `setting`                 | String | 예     | 설정 타입. DateTime 제어의 경우 `"datetime"` 값 사용            |
| `date`                    | String | 예     | 날짜 (형식: `YYYY-MM-DD`)                               |
| `time`                    | String | 예     | 시간 (형식: `HH:mm:ss`)                                 |
| `datetime_result_action`  | String | 아니요   | 결과 콜백 브로드캐스트를 위한 사용자 지정 액션                          |

###### 결과 콜백

만약 `datetime_result_action` 파라미터를 제공하면, StartUp 앱은 결과 브로드캐스트를 전송합니다:

**액션**: 사용자 지정 액션 문자열 (예: `com.example.myapp.DATETIME_RESULT`)

**결과 파라미터**:

| 파라미터                     | 타입      | 설명                                       |
|--------------------------|---------|------------------------------------------|
| `datetime_success`       | boolean | 작업이 성공하면 `true`, 실패하면 `false`            |
| `datetime_error_message` | String  | 오류 설명 (`datetime_success`가 false일 때만 존재) |

##### Date/Time 형식

###### Date 형식 (YYYY-MM-DD)

날짜는 **ISO 8601** 형식을 따릅니다:

**형식**: `YYYY-MM-DD`
- `YYYY`: 4자리 연도 (예: 2025)
- `MM`: 2자리 월 (01-12)
- `DD`: 2자리 일 (01-31)

**올바른 예제**:
```java
"2025-01-15"  // 2025년 1월 15일
"2024-12-31"  // 2024년 12월 31일
"2025-03-01"  // 2025년 3월 1일
```

###### Time 형식 (HH:mm:ss)

시간은 **24시간 형식**을 따릅니다:

**형식**: `HH:mm:ss`
- `HH`: 2자리 시 (00-23)
- `mm`: 2자리 분 (00-59)
- `ss`: 2자리 초 (00-59)

**올바른 예제**:
```java
"14:30:00"  // 오후 2시 30분 0초
"09:15:30"  // 오전 9시 15분 30초
"00:00:00"  // 자정
"23:59:59"  // 23시 59분 59초
```

###### 유효성 검증

StartUp 앱은 다음 사항을 자동으로 확인합니다:
- 날짜 형식이 올바른지 (YYYY-MM-DD)
- 시간 형식이 올바른지 (HH:mm:ss)
- 날짜가 유효한지 (예: 2월 30일은 무효)
- 시간이 유효한지 (예: 25시는 무효)

##### 주요 사항

1. **자동 날짜/시간 설정**: 기기에서 자동 날짜/시간 설정이 활성화되어 있으면 수동으로 설정한 값이 곧 덮어씌워질 수 있습니다.

2. **결과 콜백**: `datetime_result_action` 파라미터를 제공하면 성공/실패 결과를 받을 수 있습니다. 제공하지 않으면 fire-and-forget 방식으로 동작합니다.

3. **타임존**: 이 API는 날짜/시간만 설정하며 타임존은 변경하지 않습니다. 타임존을 변경하려면 별도의 Timezone API를 사용하세요.

##### ADB를 사용한 테스트

###### 날짜/시간 설정

```bash
# Set to 2025-01-15 14:30:00
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-15" --es time "14:30:00"
```

###### 결과 콜백 테스트

```bash
# Monitor result callback in logcat
adb logcat | grep "DATETIME_RESULT"

# In another terminal, send broadcast with result action
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-15" --es time "14:30:00" --es datetime_result_action "com.test.DATETIME_RESULT"
```

###### 다양한 예제

```bash
# Set to midnight (2025-01-01 00:00:00)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-01" --es time "00:00:00"

# Set to end of year (2025-12-31 23:59:59)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-12-31" --es time "23:59:59"

# Set to noon (2025-06-15 12:00:00)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-06-15" --es time "12:00:00"
```

###### 현재 날짜/시간 확인

```bash
# Check current system date and time
adb shell date

# Check in specific format
adb shell date "+%Y-%m-%d %H:%M:%S"
```

###### 자동 날짜/시간 설정 확인

```bash
# Check if automatic date & time is enabled
adb shell settings get global auto_time

# Disable automatic date & time (if needed for testing)
adb shell settings put global auto_time 0

# Enable automatic date & time
adb shell settings put global auto_time 1
```

---

#### 2.2.2 시간대 설정 SDK

> **참고** <br>
> 이 기능은 StartUp 버전 6.5.9 부터 지원됩니다.

##### 개요

이 SDK는 외부 안드로이드 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 타임존 설정을 제어할 수 있도록 합니다.

**지원 기기**: StartUp 앱이 설치된 모든 M3 Mobile 기기

###### 빠른 시작

**기본 사용법**

```java
// Set timezone with a specific timezone ID
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","timezone");
intent.putExtra("timezone","Asia/Seoul");

context.sendBroadcast(intent);
```

**결과 콜백 사용**

```java
// Send timezone setting and receive result
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","timezone");
intent.putExtra("timezone","America/New_York");
// The value for "timezone_result_action" can be any custom string you want.
intent.putExtra("timezone_result_action","com.example.myapp.TIMEZONE_RESULT");

context.sendBroadcast(intent);
```

##### API 참조

###### 브로드캐스트 액션

**액션**: `com.android.server.startupservice.system`

###### 파라미터

| 파라미터                     | 타입     | 필수 여부 | 설명                                  |
|--------------------------|--------|-------|-------------------------------------|
| `setting`                | String | 예     | 설정 타입. 타임존 제어의 경우 `"timezone"` 값 사용 |
| `timezone`               | String | 예     | IANA 타임존 ID (예: "Asia/Seoul")       |
| `timezone_result_action` | String | 아니요   | 결과 콜백 브로드캐스트를 위한 사용자 지정 액션          |

###### 결과 콜백

만약 `timezone_result_action` 파라미터를 제공하면, StartUp 앱은 결과 브로드캐스트를 전송합니다:

**액션**: 사용자 지정 액션 문자열 (예: `com.example.myapp.TIMEZONE_RESULT`)

**결과 파라미터**:

| 파라미터                     | 타입      | 설명                                       |
|--------------------------|---------|------------------------------------------|
| `timezone_success`       | boolean | 작업이 성공하면 `true`, 실패하면 `false`            |
| `timezone_error_message` | String  | 오류 설명 (`timezone_success`가 false일 때만 존재) |

##### 타임존 ID

###### 일반적인 타임존 ID

SDK는 표준 IANA 타임존 데이터베이스 ID를 사용합니다. 다음은 일반적으로 사용되는 몇 가지 예입니다:

**아시아**:

- `Asia/Seoul` - 한국 표준시 (UTC+9)
- `Asia/Tokyo` - 일본 표준시 (UTC+9)
- `Asia/Shanghai` - 중국 표준시 (UTC+8)
- `Asia/Hong_Kong` - 홍콩 시간 (UTC+8)
- `Asia/Singapore` - 싱가포르 시간 (UTC+8)
- `Asia/Bangkok` - 인도차이나 시간 (UTC+7)
- `Asia/Dubai` - 걸프 표준시 (UTC+4)

**아메리카**:

- `America/New_York` - 동부 표준시 (UTC-5/-4)
- `America/Chicago` - 중부 표준시 (UTC-6/-5)
- `America/Denver` - 산지 표준시 (UTC-7/-6)
- `America/Los_Angeles` - 태평양 표준시 (UTC-8/-7)
- `America/Toronto` - 동부 표준시 (캐나다)
- `America/Sao_Paulo` - 브라질리아 시간 (UTC-3/-2)

**유럽**:

- `Europe/London` - 그리니치 평균시 (UTC+0/+1)
- `Europe/Paris` - 중앙 유럽 표준시 (UTC+1/+2)
- `Europe/Berlin` - 중앙 유럽 표준시 (UTC+1/+2)
- `Europe/Moscow` - 모스크바 표준시 (UTC+3)

**태평양**:

- `Pacific/Auckland` - 뉴질랜드 표준시 (UTC+12/+13)
- `Pacific/Fiji` - 피지 시간 (UTC+12/+13)
- `Australia/Sydney` - 호주 동부 표준시 (UTC+10/+11)

**기타**:

- `UTC` - 협정 세계시 (UTC+0)
- `GMT` - 그리니치 평균시 (UTC+0)

##### 주요 사항

1. **즉시 적용**: 타임존 설정은 브로드캐스트를 보내는 즉시 시스템에 적용됩니다.

2. **결과 콜백**: `timezone_result_action` 파라미터를 제공하면 성공/실패 결과를 받을 수 있습니다. 제공하지 않으면 fire-and-forget 방식으로 동작합니다.

##### ADB를 사용한 테스트

###### 타임존 설정 (Asia/Seoul)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "timezone" --es timezone "Asia/Seoul"
```

###### 결과 콜백 테스트

```bash
# 먼저, logcat에서 결과 모니터링
adb logcat | grep "TIMEZONE_RESULT"

# 다른 터미널에서 결과 액션과 함께 브로드캐스트 전송
adb shell am broadcast -a com.android.server.startupservice.system --es setting "timezone" --es timezone "America/New_York" --es timezone_result_action "com.test.TIMEZONE_RESULT"
```

###### 잘못된 타임존 테스트 (오류 사례)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "timezone" --es timezone "InvalidTimeZone" --es timezone_result_action "com.test.TIMEZONE_RESULT"
```

---

#### 2.2.3 NTP 설정 SDK

> **참고** <br>
> 이 기능은 StartUp 버전 6.4.9 부터 지원됩니다.

##### 개요

이 SDK는 외부 Android 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 NTP(Network Time Protocol) 서버 설정을 제어할 수 있도록 합니다.

**중요**: 설정 변경은 기기 재부팅 후에 적용됩니다.

**지원 기기**: StartUp 앱이 설치된 모든 M3 Mobile 기기

###### 빠른 시작

**기본 사용법**

```java
// NTP 서버를 Google 공개 NTP 서버로 설정
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","ntp");
intent.putExtra("ntp_server","time.google.com");

context.sendBroadcast(intent);
```

##### API 참조

###### 브로드캐스트 액션

**Action**: `com.android.server.startupservice.system`

###### 파라미터

| 파라미터         | 타입     | 필수 | 설명                                                         |
|--------------|--------|----|------------------------------------------------------------|
| `setting`    | String | 예  | 설정 타입. NTP 서버 제어는 `"ntp"`를 사용합니다.                          |
| `ntp_server` | String | 예  | NTP 서버 URL 또는 IP 주소 (예: "time.google.com", "pool.ntp.org") |

###### NTP 서버 예시

| 서버 주소                 | 설명                     | 지역  |
|-----------------------|------------------------|-----|
| `time.google.com`     | Google 공개 NTP          | 글로벌 |


##### 중요 사항

###### 1. 재부팅 필요

NTP 서버 설정은 **다음 기기 재부팅 후**에 적용됩니다. 시스템에서 다음 토스트 메시지를 표시합니다.

###### 2. 결과 콜백 없음

이 API는 결과 콜백을 지원하지 않습니다.
설정은 즉시 시스템에 저장되지만 적용하려면 재부팅이 필요합니다.

###### 3. 유효성 검사

- API는 NTP 서버 주소가 유효한지 검증하지 않습니다
- 올바른 NTP 서버 URL 또는 IP 주소를 제공해야 합니다
- 잘못된 서버는 오류를 발생시키지 않지만 시간 동기화 실패를 초래할 수 있습니다

##### ADB로 테스트하기

###### NTP 서버 설정 (Google)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "ntp" --es ntp_server "time.google.com"
```

###### 설정 확인

```bash
# 현재 NTP 서버 설정 확인
adb shell settings get global ntp_server
```

---

## 2.3 Wi-Fi 설정

---

### 2.3.1 Captive Portal SDK

### Wi-Fi Captive Portal SDK

공공 Wi-Fi의 캡티브 포털(인증 페이지) 감지 기능을 제어합니다.

> **Note** <br>
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다. <br>
> [안드로이드 11 부터 지원](https://developer.android.com/about/versions/11/features/captive-portal?hl=ko)하며,
> SL20 기기는 지원하지 않습니다.

#### 브로드캐스트 액션

##### 설정 API

| 액션                                         | 목적                   |
|--------------------------------------------|----------------------|
| `com.android.server.startupservice.config` | Captive Portal 설정 변경 |

---

#### API 상세

##### 파라미터

| 파라미터      | 타입     | 값                | 설명     |
|-----------|--------|------------------|--------|
| `setting` | String | `captive_portal` | 설정 키   |
| `value`   | int    | `0`, `1`         | 활성화 여부 |

##### 기능 설명

| 값   | 상태   | 동작                              |
|-----|------|---------------------------------|
| `0` | 비활성화 | 캡티브 포털 감지 안 함, 일반 인터넷 연결 확인만 수행 |
| `1` | 활성화  | 캡티브 포털 자동 감지, 로그인 필요 시 알림 제공    |

##### 사용 사례

- **활성화(1)**: 공공 Wi-Fi가 많은 카페, 공항, 호텔 환경
- **비활성화(0)**: 회사 네트워크, 집 Wi-Fi 등 인증이 불필요한 환경

##### Kotlin 코드 예시

```kotlin
// Captive Portal 활성화
fun enableCaptivePortalDetection(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "captive_portal")
        putExtra("value", 1) // Enable
    }
    context.sendBroadcast(intent)
}

// Captive Portal 비활성화
fun disableCaptivePortalDetection(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "captive_portal")
        putExtra("value", 0) // Disable
    }
    context.sendBroadcast(intent)
}
```

##### ADB 명령어 예시

```bash
# Captive Portal 활성화
adb shell am broadcast -a com.android.server.startupservice.config --es setting "captive_portal" --ei value 1
```

```bash
# Captive Portal 비활성화
adb shell am broadcast -a com.android.server.startupservice.config --es setting "captive_portal" --ei value 0
```

##### 응답 정보

- **응답 형식**: 별도 응답 브로드캐스트 없음
- **모니터링**: 시스템 설정 > 네트워크 > Wi-Fi > 고급에서 확인 가능

---

### 2.3.2 Open Network Notification SDK

### Wi-Fi Open Network Notification SDK

> **Note** <br>
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다.

보안이 없는 Wi-Fi 네트워크 감지 알림 기능을 제어합니다.

#### 브로드캐스트 액션

##### 설정 API

| 액션                                             | 목적                              |
|------------------------------------------------|---------------------------------|
| `com.android.server.startupservice.config`     | Open Network Notification 설정 변경 |

---

#### API 상세

##### 파라미터

| 파라미터      | 타입     | 값                | 설명     |
|-----------|--------|------------------|--------|
| `setting` | String | `wifi_open_noti` | 설정 키   |
| `value`   | int    | `0`, `1`         | 활성화 여부 |

##### 기능 설명

| 값   | 상태   | 동작                            |
|-----|------|-------------------------------|
| `0` | 비활성화 | Open Network(보안 없음) 감지 알림 안 함 |
| `1` | 활성화  | Open Network 자동 감지 및 알림 표시    |

##### 사용 사례

- **활성화(1)**: 일반 사용자 환경, 보안 인식 높이기 필요
- **비활성화(0)**: 통제된 환경(기업/교육), 보안 설정이 이미 완료된 상황

##### Kotlin 코드 예시

```kotlin
// Open Network Notification 활성화
fun enableOpenNetworkNotification(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_open_noti")
        putExtra("value", 1) // Enable
    }
    context.sendBroadcast(intent)
}

// Open Network Notification 비활성화
fun disableOpenNetworkNotification(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_open_noti")
        putExtra("value", 0) // Disable
    }
    context.sendBroadcast(intent)
}
```

##### ADB 명령어 예시

```bash
# Open Network Notification 활성화
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_open_noti" --ei value 1
```

```bash
# Open Network Notification 비활성화
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_open_noti" --ei value 0
```

##### 응답 정보

- **응답 형식**: 별도 응답 브로드캐스트 없음
- **알림 동작**: 시스템 상태바에 "Open network available" 알림 표시

---

### 2.3.3 Sleep Policy SDK

### Wi-Fi Sleep Policy SDK

> **Note** <br>
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다.

화면이 꺼진 상태(대기 모드)에서 Wi-Fi 동작 방식을 제어합니다.

#### 브로드캐스트 액션

##### 설정 API

| 액션                                             | 목적                       |
|------------------------------------------------|--------------------------|
| `com.android.server.startupservice.config`     | Wi-Fi Sleep Policy 설정 변경 |

---

#### API 상세

##### 파라미터

| 파라미터      | 타입     | 값             | 설명              |
|-----------|--------|---------------|-----------------|
| `setting` | String | `wifi_sleep`  | 설정 키            |
| `value`   | int    | `0`, `1`, `2` | Sleep Policy 모드 |

##### Sleep Policy 모드

| 값   | 모드                   | 설명                                   |
|-----|----------------------|--------------------------------------|
| `0` | Never                | 화면이 꺼진 상태에서도 Wi-Fi 연결 유지 (배터리 소비 많음) |
| `1` | Only when plugged in | AC 전원 연결 시에만 Wi-Fi 유지                |
| `2` | Always               | 화면이 꺼지면 Wi-Fi 비활성화 (배터리 절약)          |

##### Kotlin 코드 예시

```kotlin
// Wi-Fi Sleep Policy 설정 - 항상 연결 유지
fun setWifiSleepPolicyNever(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_sleep")
        putExtra("value", 0) // Never
    }
    context.sendBroadcast(intent)
}

// Wi-Fi Sleep Policy 설정 - 화면 꺼질 때 Wi-Fi 비활성화
fun setWifiSleepPolicyAlways(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_sleep")
        putExtra("value", 2) // Always
    }
    context.sendBroadcast(intent)
}

// Wi-Fi Sleep Policy 설정 - 전원 연결 시에만 유지
fun setWifiSleepPolicyPluggedOnly(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_sleep")
        putExtra("value", 1) // Only when plugged in
    }
    context.sendBroadcast(intent)
}
```

##### ADB 명령어 예시

```bash
# Wi-Fi 항상 연결 유지 (Sleep Policy: Never)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_sleep" --ei value 0
```

```bash
# Wi-Fi 항상 연결 유지 (Sleep Policy: Never)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_sleep" --ei value 1
```

```bash
# Wi-Fi 화면 꺼질 때 비활성화 (Sleep Policy: Always)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_sleep" --ei value 2
```

##### 응답 정보

- **응답 형식**: 별도 응답 브로드캐스트 없음

---

### 2.3.4 Stability SDK

### Wi-Fi Stability (안정성) SDK

Wi-Fi 연결의 안정성 수준을 설정합니다. 신호 강도 변화에 대한 재연결 정책을 제어합니다.

> **Note** <br>
> **Android 13 이상 버전에서는 호환되지 않음** <br>
> Android 13 (API 33)부터 Wi-Fi 관련 내부 정책 변경으로 인해 이 SDK를 통한 안정성 설정이 더 이상 적용되지 않습니다.

#### 브로드캐스트 액션

##### 설정 API

| 액션                                             | 목적                    |
|------------------------------------------------|-----------------------|
| `com.android.server.startupservice.config`     | Wi-Fi Stability 설정 변경 |

---

#### API 상세

##### 파라미터

| 파라미터      | 타입     | 값                | 설명     |
|-----------|--------|------------------|--------|
| `setting` | String | `wifi_stability` | 설정 키   |
| `value`   | int    | `1`, `2`         | 안정성 모드 |

##### Stability 모드

| 값   | 모드     | 설명                                   |
|-----|--------|--------------------------------------|
| `1` | Normal | 일반적인 Wi-Fi 안정성 (신호 약할 때 가끔 재연결)      |
| `2` | High   | 높은 안정성 (신호가 약해도 연결 유지 시도, 배터리 소비 증가) |

##### Kotlin 코드 예시

```kotlin
// Wi-Fi 안정성 설정 - 일반 모드
fun setWifiStabilityNormal(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_stability")
        putExtra("value", 1) // Normal
    }
    context.sendBroadcast(intent)
}

// Wi-Fi 안정성 설정 - 높은 안정성
fun setWifiStabilityHigh(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_stability")
        putExtra("value", 2) // High
    }
    context.sendBroadcast(intent)
}
```

##### ADB 명령어 예시

```bash
# Wi-Fi 안정성 설정 - 일반 모드
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_stability" --ei value 1
```

```bash
# Wi-Fi 안정성 설정 - 높은 안정성
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_stability" --ei value 2
```

##### 응답 정보

- **응답 형식**: 별도 응답 브로드캐스트 없음

---

### 2.3.5 국가 코드 SDK

### Wi-Fi 지역 설정 SDK

> **Note** <br>
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다. <br>
> SL10, SL10K 기기는 지원하지 않습니다.

#### 개요

이 SDK는 외부 Android 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 Wi-Fi 국가 코드를 설정할 수 있도록 합니다.

Wi-Fi 국가 코드는 기기가 작동하는 지역의 무선 통신 규정을 준수하도록 설정하는 중요한 값입니다.
국가마다 허용되는 Wi-Fi 채널과 전송 출력이 다르므로, 올바른 국가 코드 설정이 필요합니다.

##### 빠른 시작

###### 기본 사용법

```java
// Wi-Fi 지역을 '대한민국'으로 설정
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting","wifi_country_code");
intent.putExtra("value","KR");
context.sendBroadcast(intent);

// Wi-Fi 지역을 '미국'으로 설정
Intent intentUS = new Intent("com.android.server.startupservice.config");
intentUS.putExtra("setting","wifi_country_code");
intentUS.putExtra("value","US");
context.sendBroadcast(intentUS);

```

##### API 참조

###### 브로드캐스트 액션

**Action**: `com.android.server.startupservice.config`

###### 파라미터

| 파라미터      | 타입     | 필수 | 설명                                          |
|-----------|--------|----|---------------------------------------------|
| `setting` | String | 예  | 반드시 `"wifi_country_code"`로 설정해야 합니다.        |
| `value`   | String | 예  | ISO 3166-1 두 글자 국가 코드 (예: "KR", "US", "JP") |

---

##### 세부 설정 가이드

###### Wi-Fi 국가 코드 (Country Code)

기기가 작동하는 지역의 규정을 준수하도록 Wi-Fi 국가 코드를 설정합니다.

- **`setting` 값**: `"wifi_country_code"`
- **`value` 타입**: `String`
- **`value` 설명**: ISO 3166-1 두 글자 국가 코드

###### 주요 국가 코드 예시

| 국가 코드 | 국가명   | 설명                      |
|-------|-------|-------------------------|
| `KR`  | 대한민국  | 한국의 Wi-Fi 규정 준수         |
| `US`  | 미국    | 미국의 Wi-Fi 규정 준수         |
| `JP`  | 일본    | 일본의 Wi-Fi 규정 준수         |
| `CN`  | 중국    | 중국의 Wi-Fi 규정 준수         |
| `EU`  | 유럽 연합 | 유럽 연합의 Wi-Fi 규정 준수 (범용) |
| `GB`  | 영국    | 영국의 Wi-Fi 규정 준수         |
| `AU`  | 호주    | 호주의 Wi-Fi 규정 준수         |
| `CA`  | 캐나다   | 캐나다의 Wi-Fi 규정 준수        |

**참고**: 전체 ISO 3166-1 국가 코드 목록은 [ISO 공식 웹사이트](https://www.iso.org/iso-3166-country-codes.html)에서 확인할 수 있습니다.

---

##### 전체 예제

###### 클라이언트 앱 구현

```java
public class WifiCountryCodeController {
    private Context context;

    public WifiCountryCodeController(Context context) {
        this.context = context;
    }

    /**
     * Wi-Fi 국가 코드 설정
     *
     * @param countryCode ISO 3166-1 두 글자 국가 코드 (예: "KR", "US", "JP")
     */
    public void setCountryCode(String countryCode) {
        // 국가 코드 유효성 검증
        if (!isValidCountryCode(countryCode)) {
            Log.e("WifiCountryCodeController", "Invalid country code: " + countryCode);
            return;
        }

        // 자동으로 대문자로 변환
        String upperCountryCode = countryCode.toUpperCase();

        // Wi-Fi 국가 코드 설정 브로드캐스트 전송
        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_country_code");
        intent.putExtra("value", upperCountryCode);
        context.sendBroadcast(intent);

        Log.i("WifiCountryCodeController", "Wi-Fi country code set: " + upperCountryCode);
    }

    /**
     * 대한민국으로 설정
     */
    public void setKorea() {
        setCountryCode("KR");
    }

    /**
     * 미국으로 설정
     */
    public void setUSA() {
        setCountryCode("US");
    }

    /**
     * 일본으로 설정
     */
    public void setJapan() {
        setCountryCode("JP");
    }

    /**
     * 국가 코드 유효성 검증
     *
     * @param countryCode 국가 코드
     * @return 유효하면 true, 아니면 false
     */
    private boolean isValidCountryCode(String countryCode) {
        if (countryCode == null || countryCode.isEmpty()) {
            return false;
        }

        // ISO 3166-1: 정확히 2글자의 알파벳
        String upperCode = countryCode.toUpperCase();
        return upperCode.length() == 2 && upperCode.matches("[A-Z]{2}");
    }

    /**
     * 현재 시스템의 국가 코드 가져오기 (참고용)
     *
     * @return 현재 시스템 국가 코드 (ISO 3166-1)
     */
    public String getSystemCountryCode() {
        return Locale.getDefault().getCountry();
    }

    /**
     * 시스템의 국가 코드로 Wi-Fi 국가 코드 설정
     */
    public void setToSystemCountry() {
        String systemCountry = getSystemCountryCode();
        if (!systemCountry.isEmpty()) {
            setCountryCode(systemCountry);
        } else {
            Log.e("WifiCountryCodeController", "Cannot get system country code");
        }
    }
}
```

###### Kotlin에서 사용

```kotlin
class WifiCountryCodeController(private val context: Context) {

    /**
     * Wi-Fi 국가 코드 설정
     */
    fun setCountryCode(countryCode: String) {
        // 국가 코드 유효성 검증
        if (!isValidCountryCode(countryCode)) {
            Log.e("WifiCountryCodeController", "Invalid country code: $countryCode")
            return
        }

        // 자동으로 대문자로 변환
        val upperCountryCode = countryCode.uppercase()

        // Wi-Fi 국가 코드 설정 브로드캐스트 전송
        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_country_code")
            putExtra("value", upperCountryCode)
            context.sendBroadcast(this)
        }

        Log.i("WifiCountryCodeController", "Wi-Fi country code set: $upperCountryCode")
    }

    /**
     * 대한민국으로 설정
     */
    fun setKorea() = setCountryCode("KR")

    /**
     * 미국으로 설정
     */
    fun setUSA() = setCountryCode("US")

    /**
     * 일본으로 설정
     */
    fun setJapan() = setCountryCode("JP")

    /**
     * 국가 코드 유효성 검증
     */
    private fun isValidCountryCode(countryCode: String): Boolean {
        if (countryCode.isEmpty()) return false
        val upperCode = countryCode.uppercase()
        return upperCode.length == 2 && upperCode.matches(Regex("[A-Z]{2}"))
    }

    /**
     * 현재 시스템의 국가 코드 가져오기
     */
    fun systemCountryCode(): String {
        return Locale.getDefault().country
    }

    /**
     * 시스템의 국가 코드로 Wi-Fi 국가 코드 설정
     */
    fun setToSystemCountry() {
        val systemCountry = systemCountryCode()
        if (systemCountry.isNotEmpty()) {
            setCountryCode(systemCountry)
        } else {
            Log.e("WifiCountryCodeController", "Cannot get system country code")
        }
    }
}
```

---

##### ADB로 테스트하기

###### Wi-Fi 국가 코드 설정

```bash
# 대한민국으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_country_code" --es value "KR"
```

```bash
# 미국으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_country_code" --es value "US"
```

```bash
# 일본으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_country_code" --es value "JP"
```

---

##### 주의사항

1. **유효한 국가 코드 사용**: ISO 3166-1 표준을 따르는 두 글자 국가 코드만 사용해야 합니다.
2. **대문자 사용**: 국가 코드는 반드시 대문자로 입력해야 합니다 (예: "kr" ❌, "KR" ✅).
3. **법적 준수**: 기기가 실제로 작동하는 지역의 국가 코드를 설정해야 합니다. 잘못된 국가 코드 설정은 해당 지역의 무선 통신 규정을 위반할 수 있습니다.
4. **재시작 필요 여부**: 일부 기기에서는 국가 코드 변경 후 Wi-Fi를 껐다 켜거나 기기를 재시작해야 설정이 완전히 적용될 수 있습니다.

---

### 2.3.6 주파수 대역 SDK

### Wi-Fi 주파수 대역 설정 SDK

> **Note** <br>
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다. <br>
> SM15, SL10, SL10K 기기는 지원하지 않습니다.

#### 개요

이 SDK는 외부 Android 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 Wi-Fi 스캔 및 연결을 특정 주파수 대역(2.4GHz 또는 5GHz)으로 제한할 수 있도록 합니다.

주파수 대역을 제한하면 기기가 특정 대역의 AP만 스캔하고 연결하므로, 네트워크 환경에 맞는 최적화된 Wi-Fi 설정이 가능합니다.

지원되는 주파수 대역:
- **AUTO (0)**: 2.4GHz + 5GHz 모두 사용 (기본값)
- **5GHz만 (1)**: 5GHz 대역만 스캔 및 연결
- **2.4GHz만 (2)**: 2.4GHz 대역만 스캔 및 연결

##### 빠른 시작

###### 기본 사용법

```java
// AUTO 모드 (2.4GHz + 5GHz 모두 사용)
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 0);
context.sendBroadcast(intent);

// 5GHz만 사용
Intent intent5G = new Intent("com.android.server.startupservice.config");
intent5G.putExtra("setting", "wifi_freq_band");
intent5G.putExtra("value", 1);
context.sendBroadcast(intent5G);

// 2.4GHz만 사용
Intent intent24G = new Intent("com.android.server.startupservice.config");
intent24G.putExtra("setting", "wifi_freq_band");
intent24G.putExtra("value", 2);
context.sendBroadcast(intent24G);
```

##### API 참조

###### 브로드캐스트 액션

**Action**: `com.android.server.startupservice.config`

###### 파라미터

| 파라미터      | 타입     | 필수 | 설명                                                               |
|-----------|--------|----|------------------------------------------------------------------|
| `setting` | String | 예  | 반드시 `"wifi_freq_band"`로 설정해야 합니다.                                |
| `value`   | int    | 예  | 주파수 대역 설정 값<br>0: AUTO (2.4GHz + 5GHz)<br>1: 5GHz만<br>2: 2.4GHz만 |

---

##### 세부 설정 가이드

###### 주파수 대역 옵션

**AUTO (0) - 듀얼 밴드**
- 2.4GHz와 5GHz 모두 사용 가능
- 기기가 자동으로 최적의 대역 선택
- 대부분의 환경에서 권장되는 기본값

**5GHz만 (1)**
- 5GHz 대역만 스캔 및 연결
- 더 빠른 속도와 적은 간섭
- 5GHz AP가 있는 환경에서 권장
- 장점: 높은 대역폭, 적은 간섭
- 단점: 전파 도달 거리가 짧음

**2.4GHz만 (2)**
- 2.4GHz 대역만 스캔 및 연결
- 더 넓은 커버리지
- 2.4GHz AP만 있는 환경에서 사용
- 장점: 넓은 커버리지, 장애물 통과 우수
- 단점: 간섭 가능성 높음, 상대적으로 낮은 속도

---

##### 일반적인 사용 시나리오

###### 시나리오 1: 창고/물류센터 (2.4GHz만)

넓은 공간에서 장애물이 많은 환경:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 2); // 2.4GHz만
context.sendBroadcast(intent);
```

###### 시나리오 2: 사무실/고속 데이터 전송 (5GHz만)

간섭이 적고 고속 통신이 필요한 환경:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 1); // 5GHz만
context.sendBroadcast(intent);
```

###### 시나리오 3: 일반 환경 (AUTO)

다양한 환경에서 사용하는 경우:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 0); // AUTO
context.sendBroadcast(intent);
```

---

##### 전체 예제

###### Kotlin에서 사용

```kotlin
class WifiFrequencyController(private val context: Context) {

    /**
     * Wi-Fi 주파수 대역 설정
     */
    fun setWifiFrequencyBand(band: Int) {
        // 값 유효성 검증
        if (band !in 0..2) {
            Log.e("WifiFrequencyController", "Invalid band value: $band")
            return
        }

        // Wi-Fi 주파수 대역 설정 브로드캐스트 전송
        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_freq_band")
            putExtra("value", band)
            context.sendBroadcast(this)
        }

        Log.i("WifiFrequencyController", "Wi-Fi frequency band set to: ${getBandName(band)}")
    }

    /**
     * AUTO 모드 설정 (2.4GHz + 5GHz)
     */
    fun setAuto() = setWifiFrequencyBand(0)

    /**
     * 5GHz만 사용
     */
    fun set5GHzOnly() = setWifiFrequencyBand(1)

    /**
     * 2.4GHz만 사용
     */
    fun set24GHzOnly() = setWifiFrequencyBand(2)

    /**
     * 대역 이름 반환
     */
    private fun getBandName(band: Int): String = when (band) {
        0 -> "AUTO (2.4GHz + 5GHz)"
        1 -> "5GHz only"
        2 -> "2.4GHz only"
        else -> "Unknown"
    }
}
```

---

##### ADB로 테스트하기

###### AUTO 모드 (2.4GHz + 5GHz)

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 0
```

###### 5GHz만 사용

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 1
```

###### 2.4GHz만 사용

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 2
```

---

##### 주의사항

1. **재연결 필요**: 주파수 대역 설정 변경 후에는 Wi-Fi를 껐다 켜거나 기기를 재시작해야 설정이 완전히 적용될 수 있습니다.

2. **네트워크 환경 고려**:
   - 5GHz 전용 모드 설정 시 2.4GHz AP만 있는 환경에서는 연결 불가
   - 2.4GHz 전용 모드 설정 시 5GHz AP만 있는 환경에서는 연결 불가

3. **기기별 구현 차이**: 일부 기기에서는 내부 구현 방식이 다를 수 있으나, SDK 사용 방법은 동일합니다.

4. **wifi-channel-sdk와 함께 사용**: 더 세밀한 채널 제어가 필요한 경우 wifi-channel-sdk와 연계하여 사용할 수 있습니다.

5. **기본값**: 설정하지 않은 경우 AUTO 모드(0)가 기본값입니다.

---

### 2.3.7 채널 SDK

### Wi-Fi 채널 설정 SDK

> **Note** <br>
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다. <br>
> SM15, SL10, SL10K 기기는 지원하지 않습니다.

#### 개요

이 SDK는 외부 Android 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해
기기의 Wi-Fi 스캔 및 연결을 특정 채널로 제한할 수 있도록 합니다.

Wi-Fi 채널을 제한하면 기기가 특정 채널의 AP만 스캔하고 연결하므로,
불필요한 채널을 차단하여 연결 속도를 개선하거나 특정 네트워크 정책을 적용할 수 있습니다.

지원되는 채널:
- **2.4 GHz 대역**: 채널 1 ~ 13
- **5 GHz 대역**: 채널 36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144, 149, 153, 157, 161, 165

> **⚠️ 중요**: US30 등 일부 기기에서는 한 주파수 대역의 채널만 설정할 경우, 설정하지 않은 다른 주파수 대역의 모든 채널이 활성화됩니다.

##### 빠른 시작

###### 기본 사용법

```java
// Wi-Fi 채널을 1, 6, 11 (2.4GHz) 및 36, 40 (5GHz)으로 제한
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_channel");
String[] channels = {"1", "6", "11", "36", "40"};
intent.putExtra("value", channels);
context.sendBroadcast(intent);

// 2.4GHz 채널만 사용 (1, 6, 11)
Intent intent24 = new Intent("com.android.server.startupservice.config");
intent24.putExtra("setting", "wifi_channel");
String[] channels24 = {"1", "6", "11"};
intent24.putExtra("value", channels24);
context.sendBroadcast(intent24);

// 5GHz 채널만 사용 (36, 40, 149, 153)
Intent intent5 = new Intent("com.android.server.startupservice.config");
intent5.putExtra("setting", "wifi_channel");
String[] channels5 = {"36", "40", "149", "153"};
intent5.putExtra("value", channels5);
context.sendBroadcast(intent5);
```

##### API 참조

###### 브로드캐스트 액션

**Action**: `com.android.server.startupservice.config`

###### 파라미터

| 파라미터      | 타입       | 필수 | 설명                                             |
|-----------|----------|----|------------------------------------------------|
| `setting` | String   | 예  | 반드시 `"wifi_channel"`로 설정해야 합니다.                |
| `value`   | String[] | 예  | 활성화할 Wi-Fi 채널 번호의 문자열 배열 (예: {"1", "6", "11"}) |

---

#### ⚠️ 특정 기기에서의 주의사항

##### US30 등 일부 기기의 동작 특성

US30을 비롯한 일부 기기에서는 Wi-Fi 채널 설정 시 다음과 같은 특성이 있습니다:

**문제점**:
- 한 주파수 대역(2.4GHz 또는 5GHz)의 채널만 설정하면, 설정하지 않은 다른 대역의 **모든 채널이 활성화**됩니다.

##### 해결 방법: wifi-frequency-sdk 사용

이 문제를 해결하려면 **wifi-frequency-sdk**를 먼저 사용하여 원하는 주파수 대역만 활성화해야 합니다.

###### 해결 방법 1: 2.4GHz 채널만 사용하고 싶은 경우

```java
// 1단계: wifi-frequency-sdk로 2.4GHz 대역만 활성화
Intent freqIntent = new Intent("com.android.server.startupservice.config");
freqIntent.putExtra("setting", "wifi_freq_band");
freqIntent.putExtra("value", 2); // 2.4GHz만
context.sendBroadcast(freqIntent);

// 2단계: wifi-channel-sdk로 2.4GHz 대역의 특정 채널 제한
Intent channelIntent = new Intent("com.android.server.startupservice.config");
channelIntent.putExtra("setting", "wifi_channel");
String[] channels = {"1", "6", "11"};
channelIntent.putExtra("value", channels);
context.sendBroadcast(channelIntent);

// ✅ 결과: 2.4GHz의 1, 6, 11 채널만 활성화됨
```

###### 해결 방법 2: 5GHz 채널만 사용하고 싶은 경우

```java
// 1단계: wifi-frequency-sdk로 5GHz 대역만 활성화
Intent freqIntent = new Intent("com.android.server.startupservice.config");
freqIntent.putExtra("setting", "wifi_freq_band");
freqIntent.putExtra("value", 1); // 5GHz만
context.sendBroadcast(freqIntent);

// 2단계: wifi-channel-sdk로 5GHz 대역의 특정 채널 제한
Intent channelIntent = new Intent("com.android.server.startupservice.config");
channelIntent.putExtra("setting", "wifi_channel");
String[] channels = {"36", "40", "44", "48", "149", "153", "157", "161", "165"};
channelIntent.putExtra("value", channels);
context.sendBroadcast(channelIntent);

// ✅ 결과: 5GHz의 비DFS 채널만 활성화됨
```

---

##### 세부 설정 가이드

###### 2.4 GHz 채널 (채널 1 ~ 14)

| 채널 | 중심 주파수   | 사용 지역      | 비고                  |
|----|----------|------------|---------------------|
| 1  | 2412 MHz | 전 세계       | 비중첩 채널 (권장)         |
| 6  | 2437 MHz | 전 세계       | 비중첩 채널 (권장)         |
| 11 | 2462 MHz | 전 세계       | 비중첩 채널 (권장)         |
| 12 | 2467 MHz | 유럽, 아시아 일부 |                     |
| 13 | 2472 MHz | 유럽, 아시아 일부 |                     |
| 14 | 2484 MHz | 일본만        | 특수 채널 (802.11b만 지원) |

**2.4 GHz 채널 선택 가이드**:
- **비중첩 채널 (1, 6, 11)**: 간섭을 최소화하기 위해 권장되는 채널 조합

###### 5 GHz 채널

**UNII-1 (실내용, 낮은 출력)**

| 채널 | 중심 주파수   | 대역폭    |
|----|----------|--------|
| 36 | 5180 MHz | 20 MHz |
| 40 | 5200 MHz | 20 MHz |
| 44 | 5220 MHz | 20 MHz |
| 48 | 5240 MHz | 20 MHz |

**UNII-2 (DFS 필요)**

| 채널  | 중심 주파수   | 대역폭    | 비고     |
|-----|----------|--------|--------|
| 52  | 5260 MHz | 20 MHz | DFS 채널 |
| 56  | 5280 MHz | 20 MHz | DFS 채널 |
| 60  | 5300 MHz | 20 MHz | DFS 채널 |
| 64  | 5320 MHz | 20 MHz | DFS 채널 |
| 100 | 5500 MHz | 20 MHz | DFS 채널 |
| 104 | 5520 MHz | 20 MHz | DFS 채널 |
| 108 | 5540 MHz | 20 MHz | DFS 채널 |
| 112 | 5560 MHz | 20 MHz | DFS 채널 |
| 116 | 5580 MHz | 20 MHz | DFS 채널 |
| 120 | 5600 MHz | 20 MHz | DFS 채널 |
| 124 | 5620 MHz | 20 MHz | DFS 채널 |
| 128 | 5640 MHz | 20 MHz | DFS 채널 |
| 132 | 5660 MHz | 20 MHz | DFS 채널 |
| 136 | 5680 MHz | 20 MHz | DFS 채널 |
| 140 | 5700 MHz | 20 MHz | DFS 채널 |
| 144 | 5720 MHz | 20 MHz | DFS 채널 |

**UNII-3 (실외용, 높은 출력)**

| 채널  | 중심 주파수   | 대역폭    | 비고           |
|-----|----------|--------|--------------|
| 149 | 5745 MHz | 20 MHz | 비DFS 채널 (권장) |
| 153 | 5765 MHz | 20 MHz | 비DFS 채널 (권장) |
| 157 | 5785 MHz | 20 MHz | 비DFS 채널 (권장) |
| 161 | 5805 MHz | 20 MHz | 비DFS 채널 (권장) |
| 165 | 5825 MHz | 20 MHz | 비DFS 채널 (권장) |

**5 GHz 채널 선택 가이드**:
- **권장 비DFS 채널**: 36, 40, 44, 48, 149, 153, 157, 161, 165
  - DFS (Dynamic Frequency Selection)가 필요없어 연결이 빠르고 안정적

---

##### 전체 예제

###### Kotlin에서 사용

```kotlin
class WifiChannelController(private val context: Context) {

    /**
     * Wi-Fi 채널 설정
     */
    fun setWifiChannels(channels: Array<String>) {
        // Wi-Fi 채널 설정 브로드캐스트 전송
        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_channel")
            putExtra("value", channels)
            context.sendBroadcast(this)
        }

        Log.i("WifiChannelController", "Wi-Fi channels set: ${channels.contentToString()}")
    }

    /**
     * 2.4 GHz 권장 채널 설정 (비중첩 채널: 1, 6, 11)
     */
    fun setRecommended24GHz() {
        setWifiChannels(arrayOf("1", "6", "11"))
    }

    /**
     * 5 GHz 권장 채널 설정 (비DFS 채널)
     */
    fun setRecommended5GHz() {
        setWifiChannels(arrayOf("36", "40", "44", "48", "149", "153", "157", "161", "165"))
    }

    /**
     * 듀얼 밴드 권장 채널 설정
     */
    fun setDualBandRecommended() {
        setWifiChannels(arrayOf(
            "1", "6", "11",  // 2.4 GHz
            "36", "40", "44", "48", "149", "153", "157", "161", "165"  // 5 GHz
        ))
    }

    /**
     * 채널 제한 해제
     */
    fun clearChannelRestrictions() {
        setWifiChannels(emptyArray())
    }
}
```

---

##### ADB로 테스트하기

###### 2.4 GHz 채널만 설정

```bash
# 비중첩 채널 (1, 6, 11)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "1","6","11"
```

###### 5 GHz 채널만 설정

```bash
# 5GHz 비DFS 채널 (36, 40, 44, 48, 149, 153, 157, 161, 165)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "36","40","44","48","149","153","157","161","165"
```

###### 듀얼 밴드 설정

```bash
# 2.4GHz + 5GHz 권장 채널
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "1","6","11","36","40","44","48","149","153","157","161","165"
```

###### US30 등 일부 기기에서 2.4GHz만 사용

```bash
# 1단계: 주파수 대역을 2.4GHz로 제한
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 2

# 2단계: 2.4GHz 채널 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "1","6","11"
```

---

##### 주의사항

**US30 등 특정 기기**: 한 주파수 대역의 채널만 설정 시 다른 대역의 모든 채널이 활성화됩니다. 이를 방지하려면:

- **방법 1**: 두 대역의 채널을 모두 명시적으로 지정
- **방법 2**: wifi-frequency-sdk를 먼저 사용하여 원하는 대역만 활성화

---

### 2.3.8 로밍 SDK

### Wi-Fi 로밍 설정 SDK

> **Note** <br>
> StartUp 버전 6.0.6 BETA 버전부터 지원합니다. <br>
> SL10, Sl10K 기기는 지원하지 않습니다.

#### 개요

이 SDK는 외부 Android 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 Wi-Fi 로밍 동작을 제어할 수 있도록 합니다.

Wi-Fi 로밍은 기기가 현재 연결된 액세스 포인트(AP)에서 더 나은 신호를 제공하는 다른 AP로 자동 전환하는 기능입니다.
이 SDK를 통해 다음 두 가지 핵심 설정을 제어할 수 있습니다:

- **Roaming Trigger (최소 Wi-Fi 신호 세기)**: 로밍을 시작하는 RSSI 임계값
- **Roaming Delta**: 새로운 AP로 전환하기 위해 필요한 최소 신호 강도 차이

##### 빠른 시작

###### 기본 사용법

```java
// Roaming Trigger를 index 1 (-75dBm)로 설정
Intent intentTrigger = new Intent("com.android.server.startupservice.config");
intentTrigger.putExtra("setting", "wifi_roam_trigger");
intentTrigger.putExtra("value", "1");
context.sendBroadcast(intentTrigger);

// Roaming Delta를 index 4 (10dB)로 설정
Intent intentDelta = new Intent("com.android.server.startupservice.config");
intentDelta.putExtra("setting", "wifi_roam_delta");
intentDelta.putExtra("value", "4");
context.sendBroadcast(intentDelta);
```

##### API 참조

###### 브로드캐스트 액션

**Action**: `com.android.server.startupservice.config`

###### 파라미터

| 파라미터      | 타입     | 필수 | 설명                                                          |
|-----------|--------|----|-------------------------------------------------------------|
| `setting` | String | 예  | 변경할 로밍 설정의 종류: `"wifi_roam_trigger"` 또는 `"wifi_roam_delta"` |
| `value`   | int    | 예  | 설정 값 (정수 인덱스)                                              |

---

##### 세부 설정 가이드

###### 1. Roaming Trigger (최소 Wi-Fi 신호 세기)

기기가 특정 RSSI (수신 신호 강도) 값 이하의 AP에 연결을 시도하지 않도록 설정합니다.

-   **`setting` 값**: `"wifi_roam_trigger"`
-   **`value` 옵션**:

| 인덱스 | RSSI 임계값 | 설명                            | 사용 시나리오                       |
|-----|----------|-------------------------------|-------------------------------|
| `0` | -80 dBm  | 신호가 매우 약해질 때까지 연결 유지          | 안정적인 연결 유지가 중요한 경우            |
| `1` | -75 dBm  | 신호가 약해지면 적극적으로 다른 AP를 찾습니다.   | AP가 많은 환경, 빠른 로밍이 필요한 경우      |
| `2` | -70 dBm  | 중간 수준의 로밍 동작 (기본 권장값)         | 일반적인 사용 환경                    |
| `3` | -65 dBm  | 신호가 더 약해질 때 로밍 시작             | 신호 품질 우선 환경                   |
| `4` | -60 dBm  | 매우 강한 신호만 유지                  | 최상의 신호 품질이 필요한 경우             |

###### 2. Roaming Delta

현재 연결된 AP와 새로 찾은 AP 간의 신호 강도 차이가 이 값보다 클 때만 로밍을 트리거합니다.

-   **`setting` 값**: `"wifi_roam_delta"`
-   **`value` 옵션**:

| 인덱스 | 신호 강도 차이 | 설명                      | 사용 시나리오                      |
|-----|----------|-------------------------|------------------------------|
| `0` | 30 dB    | 매우 큰 차이가 있을 때만 로밍      | 극도로 안정적인 연결이 필요한 경우          |
| `1` | 25 dB    | 큰 차이가 있을 때만 로밍         | 로밍 빈도 최소화                    |
| `2` | 20 dB    | 상당한 차이가 있을 때 로밍        | 안정성과 품질의 균형                  |
| `3` | 15 dB    | 중간 수준의 차이에서 로밍         | 일반적인 환경                      |
| `4` | 10 dB    | 적당한 차이에서 로밍 (기본 권장값)   | 균형잡힌 로밍 동작                   |
| `5` | 5 dB     | 더 나은 신호가 약간만 있어도 로밍    | 항상 최상의 연결 품질 유지가 필요한 경우      |
| `6` | 0 dB     | 조금이라도 나은 신호가 있으면 즉시 로밍 | 초고빈도 로밍 (일반적으로 권장하지 않음)      |

---

##### 로밍 설정 조합 가이드

###### 추천 설정 조합

| 시나리오                 | Trigger 인덱스 | Delta 인덱스 | Trigger 값 | Delta 값 | 설명                                   |
|----------------------|------------|----------|----------|--------|--------------------------------------|
| **빠른 로밍 (Aggressive)**     | 1          | 5        | -75 dBm  | 5 dB   | 신호가 조금만 약해져도 빠르게 더 나은 AP로 전환         |
| **일반적인 사용 (Moderate)**     | 2          | 4        | -70 dBm  | 10 dB  | 균형잡힌 로밍 동작 (기본 권장값)                           |
| **안정적인 연결 (Conservative)**       | 0          | 3        | -80 dBm  | 15 dB  | 불필요한 로밍을 최소화하고 현재 연결 유지              |

---

##### 전체 예제

###### Kotlin에서 사용

```kotlin
class WifiRoamingController(private val context: Context) {

    /**
     * Roaming Trigger 설정
     */
    fun setRoamTrigger(triggerIndex: Int) {
        if (triggerIndex !in 0..4) {
            Log.e("WifiRoamingController", "Invalid roam trigger index: $triggerIndex")
            return
        }

        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_roam_trigger")
            putExtra("value", triggerIndex.toString())
            context.sendBroadcast(this)
        }

        Log.i("WifiRoamingController", "Roam trigger set to index: $triggerIndex (${triggerRSSI(triggerIndex)} dBm)")
    }

    /**
     * Roaming Delta 설정
     */
    fun setRoamDelta(deltaIndex: Int) {
        if (deltaIndex !in 0..6) {
            Log.e("WifiRoamingController", "Invalid roam delta index: $deltaIndex")
            return
        }

        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_roam_delta")
            putExtra("value", deltaIndex.toString())
            context.sendBroadcast(this)
        }

        Log.i("WifiRoamingController", "Roam delta set to index: $deltaIndex (${deltaValue(deltaIndex)} dB)")
    }

    /**
     * Roaming Trigger와 Delta를 동시에 설정
     */
    fun setRoamingPolicy(triggerIndex: Int, deltaIndex: Int) {
        setRoamTrigger(triggerIndex)
        setRoamDelta(deltaIndex)
    }

    /**
     * Aggressive 로밍 설정
     */
    fun setAggressiveRoaming() = setRoamingPolicy(1, 5)

    /**
     * Moderate 로밍 설정 (기본 권장값)
     */
    fun setModerateRoaming() = setRoamingPolicy(2, 4)

    /**
     * Conservative 로밍 설정
     */
    fun setConservativeRoaming() = setRoamingPolicy(0, 3)

    /**
     * Roaming Trigger RSSI 값 가져오기
     */
    fun triggerRSSI(index: Int): Int = when (index) {
        0 -> -80
        1 -> -75
        2 -> -70
        3 -> -65
        4 -> -60
        else -> -70
    }

    /**
     * Roaming Delta 값 가져오기
     */
    fun deltaValue(index: Int): Int = when (index) {
        0 -> 30
        1 -> 25
        2 -> 20
        3 -> 15
        4 -> 10
        5 -> 5
        6 -> 0
        else -> 10
    }
}
```

---

##### ADB로 테스트하기

###### Roaming Trigger 설정

```bash
# Roaming Trigger를 index 0 (-80dBm)으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 0
```

```bash
# Roaming Trigger를 index 2 (-70dBm, 권장)로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 2
```

###### Roaming Delta 설정

```bash
# Roaming Delta를 index 4 (10dB, 권장)로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 4
```

```bash
# Roaming Delta를 index 5 (5dB)로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 5
```

###### 추천 조합 적용하기

**Aggressive 로밍 (빠른 AP 전환)**

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 1
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 5
```

**Moderate 로밍 (기본 권장)**

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 2
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 4
```

**Conservative 로밍 (안정적인 연결)**

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 0
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 3
```

---

##### 주의사항

1. **독립적인 설정**: Roaming Trigger와 Roaming Delta는 각각 독립적으로 설정할 수 있지만, 두 설정이 함께 작동하므로 조합을 고려하여 설정하는 것이 좋습니다.

2. **기본값**: 설정하지 않으면 시스템 기본값이 적용됩니다. Moderate 로밍 (Trigger=2, Delta=4)을 권장합니다.

3. **인덱스 범위**:
   - Roaming Trigger: 0-4 (5개 옵션)
   - Roaming Delta: 0-6 (7개 옵션)
   - 범위를 벗어난 값을 설정하면 무시됩니다.

---

## 2.4 시스템 설정

---

### 2.4.1 비행기 모드 SDK

### 비행기 모드 제어 SDK

> **참고** <br>
> 이 기능은 StartUp V5.3.4부터 지원됩니다.

#### 개요

이 SDK는 외부 Android 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 비행기 모드를 켜거나 끌 수 있도록 합니다.

##### 빠른 시작

###### 기본 사용법

```java
// 비행기 모드 활성화
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "airplane");
intent.putExtra("airplane", true); // true: 켜기, false: 끄기
context.sendBroadcast(intent);
```

##### API 참조

###### 브로드캐스트 액션

**Action**: `com.android.server.startupservice.system`

###### 파라미터

| 파라미터       | 타입      | 필수 | 설명                                        |
|------------|---------|----|-------------------------------------------|
| `setting`  | String  | 예  | 설정 타입. 비행기 모드 제어는 `"airplane"`을 사용합니다.    |
| `airplane` | boolean | 예  | 비행기 모드 상태. `true`는 활성화, `false`는 비활성화입니다. |

##### 중요 사항

###### 1. 즉시 적용

이 설정은 브로드캐스트를 보내는 즉시 시스템에 적용됩니다.

##### 전체 예제

###### 클라이언트 앱 구현

```java
public class AirplaneModeController {
    private Context context;

    public AirplaneModeController(Context context) {
        this.context = context;
    }

    /**
     * 비행기 모드 설정
     * @param enable true이면 활성화, false이면 비활성화
     */
    public void setAirplaneMode(boolean enable) {
        // 비행기 모드 설정 브로드캐스트 전송
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "airplane");
        intent.putExtra("airplane", enable);
        context.sendBroadcast(intent);

        Log.i("AirplaneModeController", "비행기 모드 설정 전송: " + enable);
    }
}
```

###### Activity에서 사용

```java
public class MainActivity extends AppCompatActivity {
    private AirplaneModeController airplaneModeController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        airplaneModeController = new AirplaneModeController(this);

        // 예제: 비행기 모드 켜기
        findViewById(R.id.btnAirplaneOn).setOnClickListener(v -> {
            airplaneModeController.setAirplaneMode(true);
            Toast.makeText(this, "비행기 모드를 켰습니다", Toast.LENGTH_SHORT).show();
        });

        // 예제: 비행기 모드 끄기
        findViewById(R.id.btnAirplaneOff).setOnClickListener(v -> {
            airplaneModeController.setAirplaneMode(false);
            Toast.makeText(this, "비행기 모드를 껐습니다", Toast.LENGTH_SHORT).show();
        });
    }
}
```

##### ADB로 테스트하기

ADB(Android Debug Bridge) 명령을 사용하여 터미널에서 비행기 모드 설정 기능을 테스트할 수 있습니다.

###### 비행기 모드 켜기

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "airplane" --ez airplane true
```

###### 비행기 모드 끄기

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "airplane" --ez airplane false
```

###### 설정 확인

비행기 모드 상태는 기기의 상태 표시줄이나 설정 메뉴에서 시각적으로 확인할 수 있습니다. 또는 다음 명령어로 시스템 설정을 확인할 수 있습니다.

```bash
# '1'은 켜짐, '0'은 꺼짐을 의미합니다.
adb shell settings get global airplane_mode_on
```

---

### 2.4.2 USB 설정 SDK

### USB 설정 제어 SDK

> **참고** <br>
> 이 기능은 StartUp 버전 6.5.10 부터 지원됩니다. <br>
> US20 (Android 10), US30 (Android 13) 기기에 지원됩니다.

#### 개요

이 SDK는 외부 안드로이드 애플리케이션이 StartUp 앱과의 브로드캐스트 통신을 통해 기기의 USB 모드 설정을 제어할 수 있도록 합니다.
시스템 설정에 대한 특권 액세스를 제공합니다.

##### 빠른 시작

###### 기본 사용법

```java
// Set USB mode to "No data transfer"
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","usb_setting");
intent.putExtra("usb_mode","none");

context.sendBroadcast(intent);
```

###### 결과 콜백 사용

```java
// Send USB setting and receive result
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","usb_setting");
intent.putExtra("usb_mode","mtp");
// The value for "usb_result_action" can be any custom string you want.
intent.putExtra("usb_result_action","com.example.myapp.USB_RESULT");

context.sendBroadcast(intent);
```

##### API 참조

###### 브로드캐스트 액션

**액션**: `com.android.server.startupservice.system`

###### 파라미터

| 파라미터                | 타입     | 필수 여부 | 설명                                        |
|---------------------|--------|-------|-------------------------------------------|
| `setting`           | String | 예     | 설정 타입. USB 제어의 경우 `"usb_setting"` 값 사용    |
| `usb_mode`          | String | 예     | USB 모드: "mtp", "midi", "ptp", "none" 중 하나 |
| `usb_result_action` | String | 아니요   | 결과 콜백 브로드캐스트를 위한 사용자 지정 액션                |

###### USB 모드

| 모드 값    | 설명                     | 용도                |
|---------|------------------------|-------------------|
| `mtp`   | File Transfer (MTP)    | 파일 전송 (기본 파일 관리자) |
| `rndis` | USB tethering          | 인터넷 연결 공유         |
| `midi`  | MIDI                   | 악기 연결             |
| `ptp`   | PTP (Picture Transfer) | 사진 전송             |
| `none`  | No data transfer       | 충전만 (데이터 전송 없음)   |

###### 결과 콜백

만약 `usb_result_action` 파라미터를 제공하면, StartUp 앱은 결과 브로드캐스트를 전송합니다:

**액션**: 사용자 지정 액션 문자열 (예: `com.example.myapp.USB_RESULT`)

**결과 파라미터**:

| 파라미터                | 타입      | 설명                                  |
|---------------------|---------|-------------------------------------|
| `usb_success`       | boolean | 작업이 성공하면 `true`, 실패하면 `false`       |
| `usb_error_message` | String  | 오류 설명 (`usb_success`가 false일 때만 존재) |

##### 오류 처리

###### 오류 시나리오

1. **잘못된 USB 모드**
   ```
   Error: "Invalid USB mode: invalid_mode. Valid modes are: mtp, midi, ptp, none"
   ```
   **해결책**: 유효한 USB 모드를 사용하십시오 (mtp, midi, ptp, none).

2. **지원하지 않는 Android 버전**
   ```
   Error: "USB mode control requires Android 10 or higher"
   ```
   **해결책**: Android 10 (API 29) 이상이 필요합니다.

3. **시스템 오류**
   ```
   Error: "Failed to apply USB setting: [system error details]"
   ```
   **해결책**: 시스템 권한 및 기기 상태를 확인하십시오.

##### 전체 예제

###### 클라이언트 앱 구현

```java
public class UsbController {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public UsbController(Context context) {
        this.context = context;
    }

    /**
     * Set USB mode with result callback
     * @param usbMode "mtp", "midi", "ptp", or "none"
     */
    public void setUsbMode(String usbMode) {
        // Register result receiver
        registerResultReceiver();

        // Send USB setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "usb_setting");
        intent.putExtra("usb_mode", usbMode);
        intent.putExtra("usb_result_action", "com.example.myapp.USB_RESULT");
        context.sendBroadcast(intent);

        Log.i("UsbController", "USB mode setting sent: " + usbMode);
    }

    /**
     * Register broadcast receiver for result callback
     */
    private void registerResultReceiver() {
        if (resultReceiver != null) {
            return; // Already registered
        }

        resultReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                boolean success = intent.getBooleanExtra("usb_success", false);
                String errorMessage = intent.getStringExtra("usb_error_message");

                if (success) {
                    Log.i("UsbController", "USB mode applied successfully");
                    onUsbModeSetSuccess();
                } else {
                    Log.e("UsbController", "USB mode setting failed: " + errorMessage);
                    onUsbModeSetFailed(errorMessage);
                }
            }
        };

        IntentFilter filter = new IntentFilter("com.example.myapp.USB_RESULT");
        context.registerReceiver(resultReceiver, filter);
    }

    /**
     * Unregister result receiver (call in onDestroy)
     */
    public void cleanup() {
        if (resultReceiver != null) {
            context.unregisterReceiver(resultReceiver);
            resultReceiver = null;
        }
    }

    /**
     * Override this method to handle success
     */
    protected void onUsbModeSetSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override this method to handle failure
     */
    protected void onUsbModeSetFailed(String errorMessage) {
        // Handle failure (e.g., show error dialog)
    }
}
```

##### ADB를 사용한 테스트

ADB(Android Debug Bridge) 명령어를 사용하여 터미널에서 USB 모드 제어 기능을 테스트할 수 있습니다.

###### USB 모드 설정 (No data transfer)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "none"
```

###### USB 모드 설정 (File Transfer - MTP)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "mtp"
```

###### USB 모드 설정 (MIDI)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "midi"
```

###### USB 모드 설정 (PTP)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "ptp"
```

###### 결과 콜백 테스트

```bash
# 먼저, logcat에서 결과 모니터링
adb logcat | Select-string "USB_RESULT"
# 혹은 adb logcat | grep "USB_RESULT"

# 다른 터미널에서 결과 액션과 함께 브로드캐스트 전송
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "none" --es usb_result_action "com.test.USB_RESULT"
```

---

### 2.4.3 볼륨 SDK

### 볼륨 및 사운드 SDK

#### 개요

Android-App-StartUp의 볼륨 및 사운드 설정 SDK는 외부 앱이 브로드캐스트 인텐트를 통해 기기의 다양한 오디오 스트림 볼륨을 제어할 수 있는 두 가지 API를 제공합니다.

- **CONFIG API:** 설정을 JSON으로 저장하여, 부팅 후에도 설정을 유지해야 할 때 사용합니다.
- **SYSTEM API:** 설정을 저장하지 않고, 즉시 일회성으로 볼륨을 변경할 때 사용합니다.

---

#### 브로드캐스트 액션

##### 1. CONFIG API
- **액션:** `com.android.server.startupservice.config`
- **특징:**
    - 브로드캐스트 수신 즉시 볼륨이 변경됩니다.

##### 2. SYSTEM API
- **액션:** `com.android.server.startupservice.system`
- **특징:**
    - 브로드캐스트 수신 즉시 볼륨이 변경됩니다.

두 API 는 액션 문자열만 다를 뿐 동작은 같습니다.

---

#### CONFIG API

`com.android.server.startupservice.config` 액션을 사용하며, 파라미터 이름은 `volume_` 접두사로 시작합니다.

##### 1. 미디어 볼륨

| 파라미터           | 타입  | 범위   | 설명                       |
|----------------|-----|------|--------------------------|
| `volume_media` | int | 0-15 | 미디어(음악, 비디오, 게임 등) 재생 음량 |

> **호환성 (Compatibility)**
> - 모든 기기에서 지원됩니다.

**ADB 테스트 예시:**
```bash
# 미디어 음량 10으로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_media 10
```

##### 2. 벨소리 볼륨

| 파라미터              | 타입  | 범위          | 설명                        |
|-------------------|-----|-------------|---------------------------|
| `volume_ringtone` | int | 0-7 또는 0-15 | 전화 수신음 음량. 범위는 기기별로 다릅니다. |

> **호환성 (Compatibility)**
> - **최대값 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
> - **최대값 7:** 그 외 모든 모델
>
> **기능적 제약 (Android 14+):**
> - `volume_ringtone`이 `0`으로 설정된 경우, `volume_notification`은 `0`으로 자동으로 설정됩니다.
>
> **기능적 제약 (Android 13 이하 버전):**
> - `volume_ringtone`과 `volume_notification`의 독립적인 제어가 불가능합니다.

**ADB 테스트 예시:**
```bash
# 벨소리 음량 5로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_ringtone 5
```

##### 3. 알림 볼륨

| 파라미터                  | 타입  | 범위          | 설명                     |
|-----------------------|-----|-------------|------------------------|
| `volume_notification` | int | 0-7 또는 0-15 | 알림음 음량. 범위는 기기별로 다릅니다. |

> **호환성 (Compatibility)**
> - **OS 종속성:** 이 파라미터는 **Android 14 (API 34) 이상**에서만 독립적으로 동작합니다.
> - **하위 호환성:** Android 13 이하에서는 `volume_notification` 브로드캐스트를 통한 알림 볼륨 제어가 동작하지 않습니다.

**ADB 테스트 예시:**
```bash
# 알림 음량 5로 설정 (Android 14+)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_notification 5
```

##### 4. 알람 볼륨

| 파라미터           | 타입  | 범위          | 설명                     |
|----------------|-----|-------------|------------------------|
| `volume_alarm` | int | 0-7 또는 0-15 | 알람음 음량. 범위는 기기별로 다릅니다. |

> **호환성 (Compatibility)**
> - **최대값 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `PC10`
> - **최대값 7:** 그 외 모든 모델

**ADB 테스트 예시:**
```bash
# 알람 음량 7로 설정
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_alarm 7
```

##### 5. 진동 모드

| 파라미터              | 타입      | 설명                                     |
|-------------------|---------|----------------------------------------|
| `volume_vibrator` | boolean | `true`: 진동 모드 활성화, `false`: 진동 모드 비활성화 |

> **호환성 (Compatibility)**
> - 모든 기기에서 지원됩니다.
>
> **기능적 제약:**
> - 진동 모드로 설정하면, `volume_ringtone` 과 `volume_notification` 은 자동으로 0 으로 조정됩니다.

**ADB 테스트 예시:**
```bash
# 진동 모드 활성화
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ez volume_vibrator true
```

##### CONFIG API 전체 예시

**Kotlin 예시:**
```kotlin
// 여러 볼륨 설정을 한 번에 구성
val intent = Intent("com.android.server.startupservice.config").apply {
    putExtra("setting", "volume")
    putExtra("volume_media", 10)
    putExtra("volume_ringtone", 5)
    putExtra("volume_alarm", 7)
    putExtra("volume_vibrator", false)

    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        putExtra("volume_notification", 5)
    }
}
context.sendBroadcast(intent)
```

**Java 예시:**
```java
// 여러 볼륨 설정을 한 번에 구성
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "volume");
intent.putExtra("volume_media", 10);
intent.putExtra("volume_ringtone", 5);
intent.putExtra("volume_alarm", 7);
intent.putExtra("volume_vibrator", false);

if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
    intent.putExtra("volume_notification", 5);
}
context.sendBroadcast(intent);
```

**ADB 예시:**
```bash
# 여러 볼륨을 한 번에 설정 (Android 14+ 기준) 후 적용
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_media 10 --ei volume_ringtone 5 --ei volume_notification 5 --ei volume_alarm 7 --ez volume_vibrator false
```

---

#### SYSTEM API

`com.android.server.startupservice.system` 액션을 사용하며, 파라미터 이름에 `volume_` 접두사가 없습니다.

##### 1. 미디어 볼륨

| 파라미터    | 타입  | 범위   | 설명                       |
|---------|-----|------|--------------------------|
| `media` | int | 0-15 | 미디어(음악, 비디오, 게임 등) 재생 음량 |

**ADB 테스트 예시:**
```bash
# 미디어 음량 10으로 즉시 설정
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei media 10
```

##### 2. 벨소리 볼륨

| 파라미터       | 타입  | 범위          | 설명                        |
|------------|-----|-------------|---------------------------|
| `ringtone` | int | 0-7 또는 0-15 | 전화 수신음 음량. 범위는 기기별로 다릅니다. |

**ADB 테스트 예시:**
```bash
# 벨소리 음량 5로 즉시 설정
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei ringtone 5
```

##### 3. 알림 볼륨

| 파라미터           | 타입  | 범위          | 설명                     |
|----------------|-----|-------------|------------------------|
| `notification` | int | 0-7 또는 0-15 | 알림음 음량. 범위는 기기별로 다릅니다. |

**ADB 테스트 예시:**
```bash
# 알림 음량 5로 즉시 설정 (Android 14+)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei notification 5
```

##### 4. 알람 볼륨

| 파라미터    | 타입  | 범위          | 설명                     |
|---------|-----|-------------|------------------------|
| `alarm` | int | 0-7 또는 0-15 | 알람음 음량. 범위는 기기별로 다릅니다. |

**ADB 테스트 예시:**
```bash
# 알람 음량 7로 즉시 설정
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei alarm 7
```

##### 5. 진동 모드

| 파라미터       | 타입      | 설명                                     |
|------------|---------|----------------------------------------|
| `vibrator` | boolean | `true`: 진동 모드 활성화, `false`: 진동 모드 비활성화 |

**ADB 테스트 예시:**
```bash
# 진동 모드 활성화
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ez vibrator true
```

##### SYSTEM API 전체 예시

**Kotlin 예시:**
```kotlin
// 미디어 음량을 즉시 12로 설정
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "volume")
    putExtra("media", 12)
}
context.sendBroadcast(intent)
```

**Java 예시:**
```java
// 벨소리 음량을 즉시 최대로 설정
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "volume");
intent.putExtra("ringtone", 7); // 기기 모델에 따라 최대값 확인 필요
context.sendBroadcast(intent);
```

**ADB 예시:**
```bash
# 미디어 음량을 즉시 12로, 알람 음량을 5로 설정
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei media 12 --ei alarm 5
```

---

