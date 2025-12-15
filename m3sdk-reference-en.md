# M3 SDK Reference Guide

## Table of Contents

- [1. KeyTool SDK](#1-keytool-sdk)
  - [1.1 FN Key Control SDK](#11-fn-key-control-sdk)
  - [1.2 Key Setting SDK](#12-key-setting-sdk)
- [2. Startup SDK](#2-startup-sdk)
  - [2.1 App Management](#21-app-management)
    - [2.1.1 APK Installation SDK](#211-apk-installation-sdk)
    - [2.1.2 App Enable/Disable SDK](#212-app-enabledisable-sdk)
    - [2.1.3 Runtime Permission SDK](#213-runtime-permission-sdk)
  - [2.2 Date/Time Settings](#22-datetime-settings)
    - [2.2.1 DateTime Control SDK](#221-datetime-control-sdk)
    - [2.2.2 Timezone Control SDK](#222-timezone-control-sdk)
    - [2.2.3 NTP Settings SDK](#223-ntp-settings-sdk)
  - [2.3 Wi-Fi Settings](#23-wi-fi-settings)
    - [2.3.1 Captive Portal SDK](#231-captive-portal-sdk)
    - [2.3.2 Open Network Notification SDK](#232-open-network-notification-sdk)
    - [2.3.3 Sleep Policy SDK](#233-sleep-policy-sdk)
    - [2.3.4 Stability SDK](#234-stability-sdk)
    - [2.3.5 Country Code SDK](#235-country-code-sdk)
    - [2.3.6 Frequency Band SDK](#236-frequency-band-sdk)
    - [2.3.7 Channel SDK](#237-channel-sdk)
    - [2.3.8 Roaming SDK](#238-roaming-sdk)
  - [2.4 System Settings](#24-system-settings)
    - [2.4.1 Airplane Mode SDK](#241-airplane-mode-sdk)
    - [2.4.2 USB Settings SDK](#242-usb-settings-sdk)
    - [2.4.3 Volume SDK](#243-volume-sdk)

---

## 1. KeyTool SDK

---

### 1.1 FN Key Control SDK

> **참고:** <br>
> 이 기능은 KeyTool V1.2.6 이상이면서 SL20K 기기에서 사용할 수 있습니다.

#### Overview

This SDK allows external Android applications to control the FN key state on KeyToolSL20 applications through broadcast communication. The FN key can be disabled, enabled, or locked to suit different use cases.

##### Quick Start

###### Basic Usage

```java
// Set FN key to enable state
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE");
intent.putExtra("fn_state", 1);  // 0=disable, 1=enable, 2=lock

context.sendBroadcast(intent);
```

###### Using Result Callbacks

```java
// Send FN state change and receive result
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE");
intent.putExtra("fn_state", 1);
intent.putExtra("fn_control_result_action", "com.example.myapp.FN_CONTROL_RESULT");

context.sendBroadcast(intent);
```

#### API Reference

##### Broadcast Action

**Action**: `com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE`

##### Parameters

| Parameter                  | Type    | Required | Description                                 |
|----------------------------|---------|----------|---------------------------------------------|
| `fn_state`                 | Integer | Yes      | FN state: 0=disable, 1=enable, 2=lock       |
| `fn_control_result_action` | String  | No       | Custom action for result callback broadcast |

#### FN Key States

| State Value | Name      | Description        |
|-------------|-----------|--------------------|
| `0`         | `DISABLE` | FN key is disabled |
| `1`         | `ENABLE`  | FN key is enabled  |
| `2`         | `LOCK`    | FN key is locked   |

#### Result Callbacks

If you provide the `fn_control_result_action` parameter, KeyToolSL20 will send a result broadcast:

**Action**: Custom action string you provided (e.g., `com.example.myapp.FN_CONTROL_RESULT`)

**Result Parameters**:

| Parameter                  | Type   | Description                                |
|----------------------------|--------|--------------------------------------------|
| `fn_control_result_code`   | int    | Result code (0=success, positive=error)    |
| `fn_control_error_message` | String | Error description (only when error occurs) |

##### Result Codes

| Code | Constant                                      | Description                             |
|------|-----------------------------------------------|-----------------------------------------|
| `0`  | `FN_CONTROL_RESULT_OK`                        | FN state changed successfully           |
| `1`  | `FN_CONTROL_RESULT_ERROR_SERVICE_CALL`        | Error calling PlatformService           |
| `2`  | `FN_CONTROL_RESULT_ERROR_INVALID_STATE`       | Invalid FN state value (not 0, 1, or 2) |
| `3`  | `FN_CONTROL_RESULT_ERROR_SERVICE_BIND_FAILED` | Failed to bind to PlatformService       |
| `4`  | `FN_CONTROL_RESULT_ERROR_TIMEOUT`             | PlatformService connection timeout      |

#### Complete Example

##### Java Implementation

```java
public class FnControlClient {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public FnControlClient(Context context) {
        this.context = context;
    }

    /**
     * Set FN state with result callback
     */
    public void setFnState(int state) {
        if (state < 0 || state > 2) {
            throw new IllegalArgumentException("FN state must be 0, 1, or 2");
        }

        // Register result receiver
        registerResultReceiver();

        // Send FN state setting broadcast
        Intent intent = new Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE");
        intent.putExtra("fn_state", state);
        intent.putExtra("fn_control_result_action", "com.example.myapp.FN_CONTROL_RESULT");
        context.sendBroadcast(intent);

        String stateName = getStateName(state);
        android.util.Log.i("FnControlClient", "FN state change requested: state=" + stateName);
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
                int resultCode = intent.getIntExtra("fn_control_result_code", -1);
                String errorMessage = intent.getStringExtra("fn_control_error_message");

                if (resultCode == 0) {  // FN_CONTROL_RESULT_OK
                    android.util.Log.i("FnControlClient", "FN state changed successfully");
                    onFnStateSetSuccess();
                } else {
                    android.util.Log.e("FnControlClient", "FN state change failed: " + errorMessage);
                    onFnStateSetFailed(errorMessage);
                }
            }
        };

        android.content.IntentFilter filter = new android.content.IntentFilter("com.example.myapp.FN_CONTROL_RESULT");
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
     * Override to handle success
     */
    protected void onFnStateSetSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override to handle failure
     */
    protected void onFnStateSetFailed(String errorMessage) {
        // Handle failure (e.g., show error dialog)
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

##### Kotlin Implementation

```kotlin
class FnControlClient(private val context: Context) {
    private var resultReceiver: BroadcastReceiver? = null

    /**
     * Set FN state with result callback
     */
    fun setFnState(state: Int) {
        require(state in 0..2) { "FN state must be 0, 1, or 2" }

        // Register result receiver
        registerResultReceiver()

        // Send FN state setting broadcast
        val intent = Intent("com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE").apply {
            putExtra("fn_state", state)
            putExtra("fn_control_result_action", "com.example.myapp.FN_CONTROL_RESULT")
        }
        context.sendBroadcast(intent)

        val stateName = getStateName(state)
        android.util.Log.i("FnControlClient", "FN state change requested: state=$stateName")
    }

    /**
     * Register broadcast receiver for result callback
     */
    private fun registerResultReceiver() {
        if (resultReceiver != null) {
            return // Already registered
        }

        resultReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val resultCode = intent?.getIntExtra("fn_control_result_code", -1) ?: -1
                val errorMessage = intent?.getStringExtra("fn_control_error_message")

                if (resultCode == 0) {  // FN_CONTROL_RESULT_OK
                    android.util.Log.i("FnControlClient", "FN state changed successfully")
                    onFnStateSetSuccess()
                } else {
                    android.util.Log.e("FnControlClient", "FN state change failed: $errorMessage")
                    onFnStateSetFailed(errorMessage)
                }
            }
        }

        val filter = android.content.IntentFilter("com.example.myapp.FN_CONTROL_RESULT")
        context.registerReceiver(resultReceiver, filter)
    }

    /**
     * Unregister result receiver (call in onDestroy)
     */
    fun cleanup() {
        resultReceiver?.let {
            context.unregisterReceiver(it)
            resultReceiver = null
        }
    }

    /**
     * Override to handle success
     */
    protected open fun onFnStateSetSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override to handle failure
     */
    protected open fun onFnStateSetFailed(errorMessage: String?) {
        // Handle failure (e.g., show error dialog)
    }

    private fun getStateName(state: Int): String = when (state) {
        0 -> "DISABLE"
        1 -> "ENABLE"
        2 -> "LOCK"
        else -> "UNKNOWN"
    }
}
```

##### Usage in Activity

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
                        "FN key state changed successfully", android.widget.Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onFnStateSetFailed(String errorMessage) {
                android.widget.Toast.makeText(MainActivity.this,
                        "Failed: " + errorMessage, android.widget.Toast.LENGTH_LONG).show();
            }
        };

        // Example: Set FN key to enable
        findViewById(R.id.btnEnable).setOnClickListener(v -> {
            fnControlClient.setFnState(1);
        });

        // Example: Set FN key to disable
        findViewById(R.id.btnDisable).setOnClickListener(v -> {
            fnControlClient.setFnState(0);
        });

        // Example: Set FN key to lock
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

#### Testing with ADB

You can test the FN key control functionality using ADB (Android Debug Bridge) commands from the terminal.

##### Set FN State to Enable

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 1
```

##### Set FN State to Disable

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 0
```

##### Set FN State to Lock

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 2
```

##### Testing with Result Callback

```bash
# Monitor logcat for results
adb logcat | grep "FnControlClient"

# In another terminal, send FN state change with custom result action
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE \
    --ei fn_state 1 \
    --es fn_control_result_action "com.example.myapp.FN_CONTROL_RESULT"
```

##### Testing Invalid State (Error Case)

```bash
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE --ei fn_state 5
```

#### Error Handling

##### Invalid FN State Value

**Error Message**: `"Invalid FN state: 5. Must be 0, 1, or 2."`

**Result Code**: `FN_CONTROL_RESULT_ERROR_INVALID_STATE` (2)

**Solution**: Ensure you pass a valid FN state value (0, 1, or 2).

##### Service Binding Failure

**Error Message**: `"Failed to bind to PlatformService"`

**Result Code**: `FN_CONTROL_RESULT_ERROR_SERVICE_BIND_FAILED` (3)

**Solution**:
- Verify KeyToolSL20 app is installed and running
- Check device has system privileges (sharedUserId)
- Verify no permission issues in manifest

##### Service Call Error

**Error Message**: `"RemoteException: [error details]"`

**Result Code**: `FN_CONTROL_RESULT_ERROR_SERVICE_CALL` (1)

**Solution**: Check logcat for detailed error information and system status.

##### Connection Timeout

**Error Message**: `"PlatformService connection timeout"`

**Result Code**: `FN_CONTROL_RESULT_ERROR_TIMEOUT` (4)

**Solution**:
- Ensure PlatformService is running
- Check device performance and system load
- Try the operation again after a delay

#### Constants Reference

##### Public Constants from FnControlReceiver

```kotlin
// Broadcast action
const val ACTION_CONTROL_FN_STATE = "com.m3.keytoolsl20.ACTION_CONTROL_FN_STATE"

// Result codes
const val FN_CONTROL_RESULT_OK = 0
const val FN_CONTROL_RESULT_CANCELED = -1
const val FN_CONTROL_RESULT_ERROR_SERVICE_CALL = 1
const val FN_CONTROL_RESULT_ERROR_INVALID_STATE = 2
const val FN_CONTROL_RESULT_ERROR_SERVICE_BIND_FAILED = 3
const val FN_CONTROL_RESULT_ERROR_TIMEOUT = 4

// Result message key
const val FN_CONTROL_EXTRA_ERROR_MESSAGE = "fn_control_error_message"
```

---

### 1.2 Key Setting SDK

> **Note:** <br>
> This feature is available in KeyTool V1.2.6 or higher and only on SL20, SL20P, and SL20K.

#### Overview

This SDK allows external Android applications to remap physical keys on KeyToolSL20 applications through broadcast communication. External apps can change the function assigned to any physical key and enable or disable wake-up functionality for that key.

##### Quick Start

###### Basic Usage

```java
// Remap a physical key to a new function
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Left Scan");  // Key to remap
intent.putExtra("key_function", "Scan");    // New function
intent.putExtra("key_wakeup", false);       // Wake-up enabled?

context.sendBroadcast(intent);
```

###### Control Wake-up Only

```java
// Enable wake-up for a key without changing function
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Right Scan");
intent.putExtra("key_wakeup", true);

context.sendBroadcast(intent);
```

###### Change Function Only

```java
// Change key function without modifying wake-up settings
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Left Scan");
intent.putExtra("key_function", "Scan");

context.sendBroadcast(intent);
```

###### Control Function and Wake-up Together

```java
// Remap a key and receive result
Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
intent.putExtra("key_title", "Left Scan");
intent.putExtra("key_function", "com.example.myapp");
intent.putExtra("key_wakeup", true);
intent.putExtra("key_setting_result_action", "com.example.myapp.KEY_SETTING_RESULT");

context.sendBroadcast(intent);
```

#### API Reference

##### Broadcast Action

**Action**: `com.m3.keytoolsl20.ACTION_SET_KEY`

##### Parameters

| Parameter                   | Type    | Required | Description                                               |
|-----------------------------|---------|----------|-----------------------------------------------------------|
| `key_title`                 | String  | Yes      | Key name to remap (e.g., "Left Scan")                     |
| `key_function`              | String  | No       | New function assignment (e.g., "Scan", "com.example.app") |
| `key_wakeup`                | boolean | No       | Enable/disable wake-up for this key                       |
| `key_setting_result_action` | String  | No       | Custom action for result callback broadcast               |

**Important**: At least **one of** `key_function` or `key_wakeup` must be provided. (Both cannot be omitted)


#### Supported Keys and Assignable Functions

The available keys and assignable functions vary depending on the device model.

##### SL20, SL25

###### Supported Keys
- `"Left Scan"` - Left scan button
- `"Right Scan"` - Right scan button (if available)
- `"Volume Up"` - Volume up key
- `"Volume Down"` - Volume down key
- `"Back"` - Back button
- `"Home"` - Home button
- `"Recent"` - Recent apps button
- `"Camera"` - Camera button

###### Assignable Functions
- **System Functions**: `"Default"`, `"Disable"`, `"Scan"`, `"Volume up"`, `"Volume down"`, `"Back"`, `"Home"`, `"Menu"`, `"Camera"`
- **Special Functions**: `"★"`
- **Custom App**: Package name (e.g., `"com.example.myapp"`)

##### SL20P

###### Supported Keys
- `"Left Scan"`, `"Right Scan"`, `"Volume Up"`, `"Volume Down"`, `"Back"`, `"Home"`, `"Recent"`, `"Camera"`

###### Assignable Functions
- **System Functions**: `"Default"`, `"Disable"`, `"Scan"`, `"Volume up"`, `"Volume down"`, `"Back"`, `"Home"`, `"Menu"`, `"Camera"`
- **Special Functions**: `"★"`
- **Custom App**: Package name (e.g., `"com.example.myapp"`)
- **Keyboard Input**:
    - **Function Keys**: `"F1"` to `"F12"`
    - **Navigation Keys**: `"↑"`, `"↓"`, `"←"`, `"→"`, `"Enter"`, `"Tab"`, `"Space"`, `"Del"`, `"ESC"`, `"Search"`
    - **Alphanumeric**: `"A"`-`"Z"`, `"a"`-`"z"`, `"0"`-`"9"`
    - **Special Characters**: `"`!`, `"@"`, `"#"` etc. (including `"£"`, `"€"`, `"¥"`, `"₩"`)

##### SL20K

###### Supported Keys
- **Scan and Physical Buttons**: `"Left Scan"`, `"Right Scan"`, `"Volume Up"`, `"Volume Down"`, `"Back"`, `"Home"`, `"Recent"`, `"Camera"`, `"Front Scan"`
- **Navigation and Function Keys**: `"←"`, `"↑"`, `"↓"`, `"→"`, `"Enter"`, `"Esc"`, `"Tab"`, `"Shift"`, `"Delete"`, `"Alt"`, `"Ctrl"`, `"Fn"`
- **Function Keys**: `"F1"` to `"F8"`
- **Alphanumeric**: `"A"`-`"Z"`, `"0"`-`"9"`
- **Special Characters**: `"."`, `"★"`

###### Assignable Functions
- [Supports all functions available on SL20P](#assignable-functions-1).

##### WD10

- Currently under development.

#### Result Callbacks

If you provide the `key_setting_result_action` parameter, KeyToolSL20 will send a result broadcast:

**Action**: Custom action string you provided (e.g., `com.example.myapp.KEY_SETTING_RESULT`)

**Result Parameters**:

| Parameter                   | Type   | Description                                |
|-----------------------------|--------|--------------------------------------------|
| `key_setting_result_code`   | int    | Result code (0=success, positive=error)    |
| `key_setting_error_message` | String | Error description (only when error occurs) |

##### Result Codes

| Code | Constant                                 | Description                     |
|------|------------------------------------------|---------------------------------|
| `0`  | `KEY_SETTING_RESULT_OK`                  | Key setting succeeded           |
| `1`  | `KEY_SETTING_RESULT_ERROR_INVALID_KEY`   | Key title not found             |
| `2`  | `KEY_SETTING_RESULT_ERROR_FILE_WRITE`    | Failed to save settings to file |
| `3`  | `KEY_SETTING_RESULT_ERROR_MISSING_PARAM` | Required parameters missing     |

#### Complete Example

##### Java Implementation

```java
public class KeySettingClient {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public KeySettingClient(Context context) {
        this.context = context;
    }

    /**
     * Set key mapping with result callback
     */
    public void setKeyMapping(String keyTitle, String keyFunction, boolean enableWakeup) {
        if (keyTitle == null || keyTitle.isEmpty() || keyFunction == null || keyFunction.isEmpty()) {
            throw new IllegalArgumentException("Key title and function cannot be empty");
        }

        // Register result receiver
        registerResultReceiver();

        // Send key setting broadcast
        Intent intent = new Intent("com.m3.keytoolsl20.ACTION_SET_KEY");
        intent.putExtra("key_title", keyTitle);
        intent.putExtra("key_function", keyFunction);
        intent.putExtra("key_wakeup", enableWakeup);
        intent.putExtra("key_setting_result_action", "com.example.myapp.KEY_SETTING_RESULT");
        context.sendBroadcast(intent);

        android.util.Log.i("KeySettingClient", "Key mapping request sent: title=" + keyTitle + ", function=" + keyFunction);
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
                int resultCode = intent.getIntExtra("key_setting_result_code", -1);
                String errorMessage = intent.getStringExtra("key_setting_error_message");

                if (resultCode == 0) {  // KEY_SETTING_RESULT_OK
                    android.util.Log.i("KeySettingClient", "Key mapping changed successfully");
                    onKeyMappingSuccess();
                } else {
                    android.util.Log.e("KeySettingClient", "Key mapping change failed: " + errorMessage);
                    onKeyMappingFailed(errorMessage);
                }
            }
        };

        android.content.IntentFilter filter = new android.content.IntentFilter("com.example.myapp.KEY_SETTING_RESULT");
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
     * Override to handle success
     */
    protected void onKeyMappingSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override to handle failure
     */
    protected void onKeyMappingFailed(String errorMessage) {
        // Handle failure (e.g., show error dialog)
    }
}
```

##### Kotlin Implementation

```kotlin
class KeySettingClient(private val context: Context) {
    private var resultReceiver: BroadcastReceiver? = null

    /**
     * Set key mapping with result callback
     */
    fun setKeyMapping(keyTitle: String, keyFunction: String, enableWakeup: Boolean) {
        require(keyTitle.isNotEmpty()) { "Key title cannot be empty" }
        require(keyFunction.isNotEmpty()) { "Key function cannot be empty" }

        // Register result receiver
        registerResultReceiver()

        // Send key setting broadcast
        val intent = Intent("com.m3.keytoolsl20.ACTION_SET_KEY").apply {
            putExtra("key_title", keyTitle)
            putExtra("key_function", keyFunction)
            putExtra("key_wakeup", enableWakeup)
            putExtra("key_setting_result_action", "com.example.myapp.KEY_SETTING_RESULT")
        }
        context.sendBroadcast(intent)

        android.util.Log.i("KeySettingClient", "Key mapping request sent: title=$keyTitle, function=$keyFunction")
    }

    /**
     * Register broadcast receiver for result callback
     */
    private fun registerResultReceiver() {
        if (resultReceiver != null) {
            return // Already registered
        }

        resultReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val resultCode = intent?.getIntExtra("key_setting_result_code", -1) ?: -1
                val errorMessage = intent?.getStringExtra("key_setting_error_message")

                if (resultCode == 0) {  // KEY_SETTING_RESULT_OK
                    android.util.Log.i("KeySettingClient", "Key mapping changed successfully")
                    onKeyMappingSuccess()
                } else {
                    android.util.Log.e("KeySettingClient", "Key mapping change failed: $errorMessage")
                    onKeyMappingFailed(errorMessage)
                }
            }
        }

        val filter = android.content.IntentFilter("com.example.myapp.KEY_SETTING_RESULT")
        context.registerReceiver(resultReceiver, filter)
    }

    /**
     * Unregister result receiver (call in onDestroy)
     */
    fun cleanup() {
        resultReceiver?.let {
            context.unregisterReceiver(it)
            resultReceiver = null
        }
    }

    /**
     * Override to handle success
     */
    protected open fun onKeyMappingSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override to handle failure
     */
    protected open fun onKeyMappingFailed(errorMessage: String?) {
        // Handle failure (e.g., show error dialog)
    }
}
```

##### Usage in Activity

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
                        "Key mapping changed successfully", android.widget.Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onKeyMappingFailed(String errorMessage) {
                android.widget.Toast.makeText(MainActivity.this,
                        "Failed: " + errorMessage, android.widget.Toast.LENGTH_LONG).show();
            }
        };

        // Example: Remap left scan key to camera function
        findViewById(R.id.btnRemapToCamera).setOnClickListener(v -> {
            keySettingClient.setKeyMapping("Left Scan", "Camera", false);
        });

        // Example: Remap left scan key to open custom app
        findViewById(R.id.btnRemapToApp).setOnClickListener(v -> {
            keySettingClient.setKeyMapping("Left Scan", "com.example.myapp", true);
        });

        // Example: Remap left scan key to F1
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

#### Testing with ADB

You can test the key setting functionality using ADB (Android Debug Bridge) commands from the terminal.

##### Control Wake-up Only

```bash
# Enable wake-up for left scan key
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --ez key_wakeup true

# Disable wake-up for right scan key
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Right Scan'" --ez key_wakeup false
```

##### Change Function Only

```bash
# Change left scan key function to Scan
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Scan'"

# Change left scan key function to Volume up
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Volume up'"

# Change multiple keys to different functions
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Up'" --es key_function "'Back'"
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Down'" --es key_function "'Disable'"
```

##### Control Function and Wake-up Together

```bash
# Remap key to system function while setting wake-up
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Volume up'" --ez key_wakeup true
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Volume Up'" --es key_function "'Scan'" --ez key_wakeup false
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Right Scan'" --es key_function "'Default'" --ez key_wakeup false
```

##### Remap Key to Custom App

```bash
# Remap key to custom app without wake-up settings
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'com.example.myapplication'"

# Remap key to custom app with wake-up enabled
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'com.example.myapplication'" --ez key_wakeup true
```

##### Remap Key to Keyboard Input

```bash
# Change key to keyboard function
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'F1'"

# Change key to keyboard function with wake-up disabled
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'F1'" --ez key_wakeup false
```

##### Testing with Result Callback

```bash
# Monitor logcat for result
adb logcat | grep "KeySettingClient"

# Send key setting with custom result action
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'" --es key_function "'Scan'" --ez key_wakeup true --es key_setting_result_action "com.example.myapp.KEY_SETTING_RESULT"

# Control wake-up only with result callback
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Right Scan'" --ez key_wakeup true --es key_setting_result_action "com.example.myapp.KEY_SETTING_RESULT"
```

##### Testing Invalid Parameters (Error Cases)

```bash
# Invalid key name
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'InvalidKey'" --es key_function "'Scan'"

# Both parameters omitted (error - at least one required)
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_title "'Left Scan'"

# key_title omitted (error - required parameter)
adb shell am broadcast -a com.m3.keytoolsl20.ACTION_SET_KEY --es key_function "'Scan'"
```

#### Error Handling

##### key_title Missing

**Error Message**: `"Required parameter is missing: key_title"`

**Result Code**: `KEY_SETTING_RESULT_ERROR_MISSING_PARAM` (3)

**Solution**: Always include the `key_title` parameter in the intent.

##### Both key_function and key_wakeup Missing

**Error Message**: `"Both key_function and key_wakeup are missing. At least one is required."`

**Result Code**: `KEY_SETTING_RESULT_ERROR_MISSING_PARAM` (3)

**Solution**: Provide at least one of `key_function` or `key_wakeup` parameters.

##### Invalid Key Title

**Error Message**: `"Key not found: InvalidKeyName"`

**Result Code**: `KEY_SETTING_RESULT_ERROR_INVALID_KEY` (1)

**Solution**: Use a valid key name from the supported keys list.

##### File Write Failure

**Error Message**: `"Failed to save key settings: [error details]"`

**Result Code**: `KEY_SETTING_RESULT_ERROR_FILE_WRITE` (2)

**Solution**:
- Check device storage space
- Verify file system permissions
- Ensure KeyToolSL20 app has write access to configuration files

#### Constants Reference

##### Public Constants from KeySettingReceiver

```kotlin
// Broadcast action
const val ACTION_SET_KEY = "com.m3.keytoolsl20.ACTION_SET_KEY"

// Result codes
const val KEY_SETTING_RESULT_OK = 0
const val KEY_SETTING_RESULT_ERROR_INVALID_KEY = 1
const val KEY_SETTING_RESULT_ERROR_FILE_WRITE = 2
const val KEY_SETTING_RESULT_ERROR_MISSING_PARAM = 3

// Result message key
const val KEY_SETTING_EXTRA_ERROR_MESSAGE = "key_setting_error_message"
```

---

## 2. Startup SDK

---

### 2.1 App Management

---

#### 2.1.1 APK Installation SDK

> **Note** <br>
>
> Supported since Startup version 5.3.4.

##### Overview

This SDK provides an API that allows external applications to install APK files on the device via a broadcast intent.
It supports two methods: installing from a local file path or downloading and installing from a URL.

###### Quick Start

**Basic Usage (Local File)**

```kotlin
// Install APK from a local file
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 0)  // Local file
    putExtra("path", "/sdcard/downloads/myapp.apk")
}
context.sendBroadcast(intent)
```

**Basic Usage (URL)**

```kotlin
// Download and install APK from a URL
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 1)  // URL download
    putExtra("url", "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk")
}
context.sendBroadcast(intent)
```

##### API Reference

###### Broadcast Action

**Action**: `com.android.server.startupservice.system`

###### Parameters

| Parameter | Type   | Required             | Description                                                                                                         |
|-----------|--------|----------------------|---------------------------------------------------------------------------------------------------------------------|
| `setting` | String | Yes                  | Setting type. Use `"apk_install"` for APK installation.                                                             |
| `type`    | int    | Yes                  | Installation method. `0`: Local file, `1`: URL download.                                                            |
| `path`    | String | Required if `type=0` | Absolute path of the APK file (e.g., `/sdcard/downloads/myapp.apk`).                                                |
| `url`     | String | Required if `type=1` | APK download URL (e.g., `https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk`). |

##### Full Examples

###### Local File Installation

**Kotlin Example:**

```kotlin
// Install APK from a local file
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 0)  // Local file
    putExtra("path", "/sdcard/downloads/myapp.apk")
}
context.sendBroadcast(intent)
```

**Java Example:**
```java
// Install APK from a local file
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "apk_install");
intent.putExtra("type", 0);  // Local file
intent.putExtra("path", "/sdcard/downloads/myapp.apk");
context.sendBroadcast(intent);
```

###### Download and Install from URL

**Kotlin Example:**

```kotlin
// Download and install APK from a URL
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "apk_install")
    putExtra("type", 1)  // URL download
    putExtra("url", "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk")
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Download and install APK from a URL
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "apk_install");
intent.putExtra("type", 1);  // URL download
intent.putExtra("url", "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk");
context.sendBroadcast(intent);
```

##### Testing with ADB

###### Local File Installation

```bash
# Install APK from a local file
adb shell am broadcast -a com.android.server.startupservice.system --es setting "apk_install" --ei type 0 --es path "/sdcard/downloads/myapp.apk"
```

###### Download and Install from URL

```bash
# Download and install APK from a URL
adb shell am broadcast -a com.android.server.startupservice.system --es setting "apk_install" --ei type 1 --es url "https://github.com/skydoves/pokedex-compose/releases/download/1.0.3/pokedex-compose.apk"
```

##### Notes

- When downloading from a URL, the APK is saved in the `/data/downloads/` directory.
- URL installation requires a network connection.
- Download progress can be monitored via broadcast (`android.app.DownloadManager.ACTION_DOWNLOAD_COMPLETE`).
- Attempting to enable an app or set its permissions immediately after installation may cause timing issues. Ensure installation is complete before proceeding with subsequent actions.

##### Troubleshooting

If APK installation fails, check the following:

```bash
# 1. Check logs
adb logcat | grep -i "apk\|install"

# 2. Check if the file exists
adb shell ls -la /data/downloads/myapp.apk

# 3. Check file permissions
adb shell stat /data/downloads/myapp.apk

# 4. Verify APK integrity
adb shell md5sum /data/downloads/myapp.apk
```

---

#### 2.1.2 App Enable/Disable SDK

> **Note** <br>
>
> Supported since StartUp version 6.2.21.

##### Overview

This SDK allows external applications to enable or disable installed apps via a broadcast intent.
A disabled app cannot be launched and does not consume system resources.

###### Quick Start

**Enable App**

```kotlin
// Enable app
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.google.android.gms")
    putExtra("enable", true)
}
context.sendBroadcast(intent)
```

**Disable App**

```kotlin
// Disable app
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.example.unwantedapp")
    putExtra("enable", false)
}
context.sendBroadcast(intent)
```

##### API Reference

###### Broadcast Action

**Action**: `com.android.server.startupservice.system`

###### Parameters

| Parameter      | Type    | Required | Description                                                 |
|----------------|---------|----------|-------------------------------------------------------------|
| `setting`      | String  | Yes      | Setting type. Use `"application"` for app control.          |
| `package_name` | String  | Yes      | Package name of the target app (e.g., `com.example.myapp`). |
| `enable`       | boolean | Yes      | `true` to enable, `false` to disable.                       |

##### Full Examples

###### Enable App

**Kotlin Example:**

```kotlin
// Enable app
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.google.android.calculator")
    putExtra("enable", true)
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Enable app
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "application");
intent.putExtra("package_name", "com.google.android.calculator");
intent.putExtra("enable", true);
context.sendBroadcast(intent);
```

###### Disable App

**Kotlin Example:**

```kotlin
// Disable app
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "application")
    putExtra("package_name", "com.google.android.calculator")
    putExtra("enable", false)
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Disable app
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "application");
intent.putExtra("package_name", "com.google.android.calculator");
intent.putExtra("enable", false);
context.sendBroadcast(intent);
```

##### Testing with ADB

###### Enable App

```bash
# Enable app
adb shell am broadcast -a com.android.server.startupservice.system --es setting "application" --es package_name "com.google.android.calculator" --ez enable true
```

###### Disable App

```bash
# Disable app
adb shell am broadcast -a com.android.server.startupservice.system --es setting "application" --es package_name "com.google.android.calculator" --ez enable false
```

##### Notes

- System apps can also be disabled, but caution is advised as it may affect system stability.
- A disabled app will not run in the background and will not send notifications.
- To re-enable a disabled app, simply send the broadcast again with `enable: true`.

##### Troubleshooting

If you encounter issues after disabling an app, check the following:

```bash
# 1. List disabled apps
adb shell pm list packages -d

# 2. Re-enable the app
adb shell pm enable com.example.app

# 3. Force-stop and then enable the app
adb shell am force-stop com.example.app
adb shell pm enable com.example.app
```

---

#### 2.1.3 Runtime Permission SDK

> **Note** <br>
> **Supported Devices**: Android 6.0 (API 23) and higher
> Supported since StartUp app version 6.4.17.

##### Overview

This SDK allows external applications to grant or revoke dangerous permissions for other apps via a broadcast intent.
This feature is useful in scenarios where permissions need to be controlled without user interaction.

###### Quick Start

**Grant Permission**

```kotlin
// Grant CAMERA permission
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 1)  // Grant
}
context.sendBroadcast(intent)
```

**Deny Permission**

```kotlin
// Deny CAMERA permission
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 2)  // Deny (Important: use 2)
}
context.sendBroadcast(intent)
```

##### API Reference

###### Broadcast Action

**Action**: `com.android.server.startupservice.system`

###### Parameters

| Parameter         | Type   | Required | Description                                              |
|-------------------|--------|----------|----------------------------------------------------------|
| `setting`         | String | Yes      | Setting type. Use `"permission"` for permission control. |
| `package`         | String | Yes      | Package name of the target app.                          |
| `permission`      | String | Yes      | Permission name (e.g., `android.permission.CAMERA`).     |
| `permission_mode` | int    | Yes      | `1`=Grant, `2`=Deny.                                     |

**Detailed `permission_mode` values**:
- **1 (GRANT)**: Grants the permission. The app can use the corresponding feature.
- **2 (DENY)**: Denies the permission. The app cannot use the corresponding feature.

###### Supported Dangerous Permissions

This SDK supports all **Android Dangerous Permissions**. Key permissions include:

- **Camera**: `android.permission.CAMERA`
- **Location**: `android.permission.ACCESS_FINE_LOCATION`, `android.permission.ACCESS_COARSE_LOCATION`
- **Contacts**: `android.permission.READ_CONTACTS`, `android.permission.WRITE_CONTACTS`
- **Phone**: `android.permission.CALL_PHONE`, `android.permission.READ_CALL_LOG`, `android.permission.WRITE_CALL_LOG`, `android.permission.READ_PHONE_STATE`
- **Microphone**: `android.permission.RECORD_AUDIO`
- **Files/Media** (Android 12 and below): `android.permission.READ_EXTERNAL_STORAGE`, `android.permission.WRITE_EXTERNAL_STORAGE`
- **Media** (Android 13+): `android.permission.READ_MEDIA_IMAGES`, `android.permission.READ_MEDIA_VIDEO`, `android.permission.READ_MEDIA_AUDIO`
- **Calendar**: `android.permission.READ_CALENDAR`, `android.permission.WRITE_CALENDAR`
- **SMS**: `android.permission.READ_SMS`, `android.permission.SEND_SMS`
- **Sensors**: `android.permission.BODY_SENSORS`
- **Notifications** (Android 13+): `android.permission.POST_NOTIFICATIONS`
- **Other**: `android.permission.ACCESS_MEDIA_LOCATION`

###### Constraints

Permission control is **not possible** in the following cases:

1.  **Permission not declared by the app**: The target app must declare the permission in its `AndroidManifest.xml`.
2.  **System-fixed permissions**: Permissions with the `SYSTEM_FIXED` or `POLICY_FIXED` flag cannot be changed.
    -   E.g., The CAMERA permission for the system camera app, or the CALL_PHONE permission for the default phone app.
3.  **Install-time permissions**: Normal permissions are not subject to runtime control.

**How to check permission flags**:
```bash
adb shell dumpsys package [package_name] | findstr "[permission_name]"
```

Example output:
```
android.permission.CAMERA: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT ]
```
In this case, control is not possible due to the `SYSTEM_FIXED` flag.

##### Full Examples

###### Grant Permission

**Kotlin Example:**

```kotlin
// Grant CAMERA permission
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 1)  // Grant
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Grant CAMERA permission
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "permission");
intent.putExtra("package", "com.example.cameraapp");
intent.putExtra("permission", "android.permission.CAMERA");
intent.putExtra("permission_mode", 1);  // Grant
context.sendBroadcast(intent);
```

###### Deny Permission

**Kotlin Example:**

```kotlin
// Deny CAMERA permission
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "permission")
    putExtra("package", "com.example.cameraapp")
    putExtra("permission", "android.permission.CAMERA")
    putExtra("permission_mode", 2)  // Deny (Important: use 2)
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Deny CAMERA permission
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "permission");
intent.putExtra("package", "com.example.cameraapp");
intent.putExtra("permission", "android.permission.CAMERA");
intent.putExtra("permission_mode", 2);  // Deny (Important: use 2)
context.sendBroadcast(intent);
```

###### Batch Permission Control

To control multiple permissions simultaneously, send a separate broadcast for each permission.

```kotlin
// Grant multiple permissions at once
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
            putExtra("permission_mode", 1)  // Grant
        }
        context.sendBroadcast(intent)
    }
}

// Example usage
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

##### Testing with ADB

###### Grant Permission

```bash
# Grant microphone permission to YouTube
adb shell am broadcast -a com.android.server.startupservice.system --es setting "permission" --es package "com.google.android.youtube" --es permission "android.permission.RECORD_AUDIO" --ei permission_mode 1
```

###### Deny Permission

```bash
# Deny microphone permission to YouTube
adb shell am broadcast -a com.android.server.startupservice.system --es setting "permission" --es package "com.google.android.youtube" --es permission "android.permission.RECORD_AUDIO" --ei permission_mode 2
```

###### Check Permission Status

```bash
# Check status of a specific permission (Windows)
adb shell dumpsys package com.google.android.youtube | findstr "RECORD_AUDIO"

# Example output:
# android.permission.RECORD_AUDIO: granted=true, flags=[ POLICY_FIXED|USER_SENSITIVE_WHEN_GRANTED ]
```

```bash
# Check all runtime permissions (Windows)
adb shell dumpsys package com.google.android.youtube | findstr "granted"
```

##### Troubleshooting

###### Permission change is not applied

**1. Check if the app declared the permission**

```bash
# Check permission on Windows
adb shell dumpsys package com.example.app | findstr "android.permission.CAMERA"

# If there is no output, the app has not declared the permission.
```

**2. Check permission flags**

```bash
adb shell dumpsys package com.example.app | findstr "CAMERA"

# Example output:
# android.permission.CAMERA: granted=true, flags=[ SYSTEM_FIXED|GRANTED_BY_DEFAULT ]
```

- If `SYSTEM_FIXED` or `POLICY_FIXED` flag is present, it cannot be controlled.
- This is often set for core permissions of system or default apps.

**3. Check if `permission_mode` value is correct**

```bash
# Incorrect example (using 0 to deny)
--ei permission_mode 0  # Restores to default (not a denial!)

# Correct example (deny)
--ei permission_mode 2  # Explicit denial
```

**4. Check system permission list**

```bash
# Check all dangerous permission groups
adb shell pm list permissions -g -d

# Check permissions requested by a specific app
adb shell dumpsys package com.example.app | findstr "requested permissions"
```

###### Common Error Scenarios

| Symptom                                              | Cause                                                       | Solution                                           |
|------------------------------------------------------|-------------------------------------------------------------|----------------------------------------------------|
| Log shows `result: true` but permission is unchanged | Using `permission_mode=0` (restores default)                | Use `permission_mode=2` (to deny)                  |
| Permission not in app's permission list              | App did not declare the permission in `AndroidManifest.xml` | Test with another app that declares the permission |
| `SYSTEM_FIXED` flag                                  | Core permission of a system app                             | Cannot be controlled, test with another app        |
| Permission changes but app behavior doesn't          | App is using a cached permission state                      | Force-stop and restart the app                     |

---

### 2.2 Date/Time Settings

---

#### 2.2.1 DateTime Control SDK

> **Note** <br>
> This feature is supported from StartUp version 5.3.4 and above.

##### Overview

This SDK allows external Android applications to manually set the device's date and time through broadcast communication with the StartUp app.

###### Quick Start

**Basic Usage**

```java
// Set date and time manually
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "datetime");
intent.putExtra("date", "2025-01-15");
intent.putExtra("time", "14:30:00");
context.sendBroadcast(intent);
```

**Using Result Callback**

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

##### API Reference

###### Broadcast Action

**Action**: `com.android.server.startupservice.system`

###### Parameters

| Parameter                | Type   | Required | Description                                          |
|--------------------------|--------|----------|------------------------------------------------------|
| `setting`                | String | Yes      | Setting type. Use `"datetime"` for DateTime control. |
| `date`                   | String | Yes      | Date (format: `YYYY-MM-DD`)                          |
| `time`                   | String | Yes      | Time (format: `HH:mm:ss`)                            |
| `datetime_result_action` | String | No       | Custom action for the result callback broadcast.     |

###### Result Callback

If you provide the `datetime_result_action` parameter, the StartUp app will send a result broadcast:

**Action**: Custom action string (e.g., `com.example.myapp.DATETIME_RESULT`)

**Result Parameters**:

| Parameter                | Type    | Description                                                      |
|--------------------------|---------|------------------------------------------------------------------|
| `datetime_success`       | boolean | `true` if the operation was successful, `false` otherwise.       |
| `datetime_error_message` | String  | Error description (only present if `datetime_success` is false). |

##### Date/Time Format

###### Date Format (YYYY-MM-DD)

The date follows the **ISO 8601** format:

**Format**: `YYYY-MM-DD`
- `YYYY`: 4-digit year (e.g., 2025)
- `MM`: 2-digit month (01-12)
- `DD`: 2-digit day (01-31)

**Correct Examples**:
```java
"2025-01-15"  // January 15, 2025
"2024-12-31"  // December 31, 2024
"2025-03-01"  // March 1, 2025
```

###### Time Format (HH:mm:ss)

The time follows the **24-hour format**:

**Format**: `HH:mm:ss`
- `HH`: 2-digit hour (00-23)
- `mm`: 2-digit minute (00-59)
- `ss`: 2-digit second (00-59)

**Correct Examples**:
```java
"14:30:00"  // 2:30:00 PM
"09:15:30"  // 9:15:30 AM
"00:00:00"  // Midnight
"23:59:59"  // 11:59:59 PM
```

###### Validation

The StartUp app automatically checks for the following:
- Correct date format (YYYY-MM-DD)
- Correct time format (HH:mm:ss)
- Valid date (e.g., February 30 is invalid)
- Valid time (e.g., 25:00 is invalid)

##### Important Notes

1. **Automatic Date/Time Setting**: If automatic date/time setting is enabled on the device, the manually set value may be overwritten shortly after.

2. **Result Callback**: Providing the `datetime_result_action` parameter allows you to receive a success/failure result. If not provided, it operates in a fire-and-forget manner.

3. **Timezone**: This API only sets the date/time and does not change the timezone. To change the timezone, use a separate Timezone API.

##### Full Example

###### Client App Implementation

```java
public class DateTimeController {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public DateTimeController(Context context) {
        this.context = context;
    }

    /**
     * Set date and time with result callback
     *
     * @param date Date in YYYY-MM-DD format (e.g., "2025-01-15")
     * @param time Time in HH:mm:ss format (e.g., "14:30:00")
     */
    public void setDateTime(String date, String time) {
        // Validate format before sending
        if (!isValidDateFormat(date)) {
            Log.e("DateTimeController", "Invalid date format: " + date + " (expected: YYYY-MM-DD)");
            return;
        }

        if (!isValidTimeFormat(time)) {
            Log.e("DateTimeController", "Invalid time format: " + time + " (expected: HH:mm:ss)");
            return;
        }

        // Register result receiver
        registerResultReceiver();

        // Send datetime setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "datetime");
        intent.putExtra("date", date);
        intent.putExtra("time", time);
        intent.putExtra("datetime_result_action", "com.example.myapp.DATETIME_RESULT");
        context.sendBroadcast(intent);

        Log.i("DateTimeController", "DateTime setting sent: date=" + date + ", time=" + time);
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
                boolean success = intent.getBooleanExtra("datetime_success", false);
                String errorMessage = intent.getStringExtra("datetime_error_message");

                if (success) {
                    Log.i("DateTimeController", "DateTime setting applied successfully");
                    onDateTimeSetSuccess();
                } else {
                    Log.e("DateTimeController", "DateTime setting failed: " + errorMessage);
                    onDateTimeSetFailed(errorMessage);
                }
            }
        };

        IntentFilter filter = new IntentFilter("com.example.myapp.DATETIME_RESULT");
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
    protected void onDateTimeSetSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override this method to handle failure
     */
    protected void onDateTimeSetFailed(String errorMessage) {
        // Handle failure (e.g., show error dialog)
    }

    /**
     * Validate date format (YYYY-MM-DD)
     */
    private boolean isValidDateFormat(String date) {
        if (date == null) return false;
        return date.matches("\\d{4}-\\d{2}-\\d{2}");
    }

    /**
     * Validate time format (HH:mm:ss)
     */
    private boolean isValidTimeFormat(String time) {
        if (time == null) return false;
        return time.matches("\\d{2}:\\d{2}:\\d{2}");
    }

    /**
     * Set current system time (convenience method)
     */
    public void setToCurrentTime() {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss", Locale.US);

        Date now = new Date();
        String date = dateFormat.format(now);
        String time = timeFormat.format(now);

        setDateTime(date, time);
    }

    /**
     * Set specific date and time using Calendar
     */
    public void setDateTime(int year, int month, int day, int hour, int minute, int second) {
        String date = String.format(Locale.US, "%04d-%02d-%02d", year, month, day);
        String time = String.format(Locale.US, "%02d:%02d:%02d", hour, minute, second);
        setDateTime(date, time);
    }
}
```

###### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private DateTimeController dateTimeController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        dateTimeController = new DateTimeController(this) {
            @Override
            protected void onDateTimeSetSuccess() {
                Toast.makeText(MainActivity.this,
                        "DateTime set successfully", Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onDateTimeSetFailed(String errorMessage) {
                Toast.makeText(MainActivity.this,
                        "Failed: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        };

        // Example 1: Set specific date and time
        findViewById(R.id.btnSetDateTime1).setOnClickListener(v -> {
            dateTimeController.setDateTime("2025-01-15", "14:30:00");
        });

        // Example 2: Set current system time
        findViewById(R.id.btnSetCurrentTime).setOnClickListener(v -> {
            dateTimeController.setToCurrentTime();
        });

        // Example 3: Set using Calendar values
        findViewById(R.id.btnSetDateTime2).setOnClickListener(v -> {
            dateTimeController.setDateTime(2025, 12, 31, 23, 59, 59);
        });

        // Example 4: Set from DatePicker and TimePicker
        findViewById(R.id.btnSetFromPickers).setOnClickListener(v -> {
            showDateTimePicker();
        });
    }

    private void showDateTimePicker() {
        // Show date picker first
        Calendar calendar = Calendar.getInstance();

        new DatePickerDialog(this, (view, year, month, dayOfMonth) -> {
            // Show time picker after date is selected
            new TimePickerDialog(this, (timeView, hourOfDay, minute) -> {
                // Set datetime with selected values
                dateTimeController.setDateTime(year, month + 1, dayOfMonth,
                        hourOfDay, minute, 0);
            }, calendar.get(Calendar.HOUR_OF_DAY),
               calendar.get(Calendar.MINUTE), true).show();
        }, calendar.get(Calendar.YEAR),
           calendar.get(Calendar.MONTH),
           calendar.get(Calendar.DAY_OF_MONTH)).show();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        dateTimeController.cleanup();
    }
}
```

##### Testing with ADB

You can test the DateTime control feature from the terminal using ADB (Android Debug Bridge) commands.

###### Set Date/Time

```bash
# Set to 2025-01-15 14:30:00
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-15" --es time "14:30:00"
```

###### Test Result Callback

```bash
# Monitor result callback in logcat
adb logcat | grep "DATETIME_RESULT"

# In another terminal, send broadcast with result action
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-15" --es time "14:30:00" --es datetime_result_action "com.test.DATETIME_RESULT"
```

###### Various Examples

```bash
# Set to midnight (2025-01-01 00:00:00)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-01" --es time "00:00:00"

# Set to end of year (2025-12-31 23:59:59)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-12-31" --es time "23:59:59"

# Set to noon (2025-06-15 12:00:00)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-06-15" --es time "12:00:00"

# Test invalid date format (error case)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-1-15" --es time "14:30:00" --es datetime_result_action "com.test.DATETIME_RESULT"

# Test invalid time format (error case)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "datetime" --es date "2025-01-15" --es time "14:30" --es datetime_result_action "com.test.DATETIME_RESULT"
```

###### Log Monitoring

To monitor the DateTime setting process:

```bash
# Monitor datetime setting process
adb logcat | grep -E "handleDateTimeSetting|date :|time :"

# Monitor StartUpWork logs
adb logcat | grep "StartUpWork"
```

###### Check Current Date/Time

```bash
# Check current system date and time
adb shell date

# Check in specific format
adb shell date "+%Y-%m-%d %H:%M:%S"
```

###### Check Automatic Date/Time Setting

```bash
# Check if automatic date & time is enabled
adb shell settings get global auto_time

# Disable automatic date & time (if needed for testing)
adb shell settings put global auto_time 0

# Enable automatic date & time
adb shell settings put global auto_time 1
```

##### Related APIs

-   **Timezone Control SDK**: `timezone-setting-sdk-readme.md` - Controls the device's timezone.
-   **NTP Configuration**: NTP server auto-synchronization can be configured through the StartUp JSON settings.

##### Troubleshooting

###### DateTime Setting Not Applied

1.  Check if the StartUp app is running:
    ```bash
    adb shell ps | grep startup
    ```

2.  Check if automatic date/time is disabled:
    ```bash
    # 0: disable 1: enable
    adb shell settings get global auto_time
    ```

3.  Check the logs to see if the broadcast was received:
    ```bash
    adb logcat | grep "STARTUP_ACTION_SYSTEM received"
    ```

4.  Verify the Date/Time format is correct (YYYY-MM-DD, HH:mm:ss).

---

#### 2.2.2 Timezone Control SDK

> **Note** <br>
> This feature is supported from StartUp version 6.5.9 and above.

##### Overview

This SDK allows external Android applications to control the device's timezone setting through broadcast communication with the StartUp app.

**Supported Devices**: All M3 Mobile devices with StartUp app installed

###### Quick Start

**Basic Usage**

```java
// Set timezone with a specific timezone ID
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","timezone");
intent.putExtra("timezone","Asia/Seoul");

context.sendBroadcast(intent);
```

**Using Result Callback**

```java
// Send timezone setting and receive result
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","timezone");
intent.putExtra("timezone","America/New_York");
// The value for "timezone_result_action" can be any custom string you want.
intent.putExtra("timezone_result_action","com.example.myapp.TIMEZONE_RESULT");

context.sendBroadcast(intent);
```

##### API Reference

###### Broadcast Action

**Action**: `com.android.server.startupservice.system`

###### Parameters

| Parameter                | Type   | Required | Description                                          |
|--------------------------|--------|----------|------------------------------------------------------|
| `setting`                | String | Yes      | Setting type. Use `"timezone"` for timezone control. |
| `timezone`               | String | Yes      | IANA timezone ID (e.g., "Asia/Seoul").               |
| `timezone_result_action` | String | No       | Custom action for the result callback broadcast.     |

###### Result Callback

If you provide the `timezone_result_action` parameter, the StartUp app will send a result broadcast:

**Action**: Custom action string (e.g., `com.example.myapp.TIMEZONE_RESULT`)

**Result Parameters**:

| Parameter                | Type    | Description                                                      |
|--------------------------|---------|------------------------------------------------------------------|
| `timezone_success`       | boolean | `true` if the operation was successful, `false` otherwise.       |
| `timezone_error_message` | String  | Error description (only present if `timezone_success` is false). |

##### Timezone IDs

###### Common Timezone IDs

The SDK uses standard IANA timezone database IDs. Here are some commonly used examples:

**Asia**:

- `Asia/Seoul` - Korea Standard Time (UTC+9)
- `Asia/Tokyo` - Japan Standard Time (UTC+9)
- `Asia/Shanghai` - China Standard Time (UTC+8)
- `Asia/Hong_Kong` - Hong Kong Time (UTC+8)
- `Asia/Singapore` - Singapore Time (UTC+8)
- `Asia/Bangkok` - Indochina Time (UTC+7)
- `Asia/Dubai` - Gulf Standard Time (UTC+4)

**Americas**:

- `America/New_York` - Eastern Time (UTC-5/-4)
- `America/Chicago` - Central Time (UTC-6/-5)
- `America/Denver` - Mountain Time (UTC-7/-6)
- `America/Los_Angeles` - Pacific Time (UTC-8/-7)
- `America/Toronto` - Eastern Time (Canada)
- `America/Sao_Paulo` - Brasília Time (UTC-3/-2)

**Europe**:

- `Europe/London` - Greenwich Mean Time (UTC+0/+1)
- `Europe/Paris` - Central European Time (UTC+1/+2)
- `Europe/Berlin` - Central European Time (UTC+1/+2)
- `Europe/Moscow` - Moscow Standard Time (UTC+3)

**Pacific**:

- `Pacific/Auckland` - New Zealand Standard Time (UTC+12/+13)
- `Pacific/Fiji` - Fiji Time (UTC+12/+13)
- `Australia/Sydney` - Australian Eastern Standard Time (UTC+10/+11)

**Other**:

- `UTC` - Coordinated Universal Time (UTC+0)
- `GMT` - Greenwich Mean Time (UTC+0)

##### Important Notes

1. **Immediate Effect**: The timezone setting is applied to the system immediately after the broadcast is sent.

2. **Result Callback**: Providing the `timezone_result_action` parameter allows you to receive a success/failure result. If not provided, it operates in a fire-and-forget manner.

##### Error Handling

###### Error Scenarios

1.  **Invalid Timezone ID**
    ```
    Error: "Invalid timezone ID: InvalidTimeZone"
    ```
    **Solution**: Use a valid IANA timezone ID (see the Timezone ID section).

2.  **System Error**
    ```
    Error: "Failed to apply timezone setting: [system error details]"
    ```
    **Solution**: Check system permissions and device status.

##### Full Example

###### Client App Implementation

```java
public class TimeZoneController {
    private Context context;
    private BroadcastReceiver resultReceiver;

    public TimeZoneController(Context context) {
        this.context = context;
    }

    /**
     * Set timezone with result callback
     */
    public void setTimeZone(String timezoneId) {
        // Register result receiver
        registerResultReceiver();

        // Send timezone setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "timezone");
        intent.putExtra("timezone", timezoneId);
        intent.putExtra("timezone_result_action", "com.example.myapp.TIMEZONE_RESULT");
        context.sendBroadcast(intent);

        Log.i("TimeZoneController", "Timezone setting sent: timezone=" + timezoneId);
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
                boolean success = intent.getBooleanExtra("timezone_success", false);
                String errorMessage = intent.getStringExtra("timezone_error_message");

                if (success) {
                    Log.i("TimeZoneController", "Timezone setting applied successfully");
                    onTimeZoneSetSuccess();
                } else {
                    Log.e("TimeZoneController", "Timezone setting failed: " + errorMessage);
                    onTimeZoneSetFailed(errorMessage);
                }
            }
        };

        IntentFilter filter = new IntentFilter("com.example.myapp.TIMEZONE_RESULT");
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
    protected void onTimeZoneSetSuccess() {
        // Handle success (e.g., show toast, update UI)
    }

    /**
     * Override this method to handle failure
     */
    protected void onTimeZoneSetFailed(String errorMessage) {
        // Handle failure (e.g., show error dialog)
    }
}
```

###### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private TimeZoneController timeZoneController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        timeZoneController = new TimeZoneController(this) {
            @Override
            protected void onTimeZoneSetSuccess() {
                Toast.makeText(MainActivity.this,
                        "Timezone set successfully", Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onTimeZoneSetFailed(String errorMessage) {
                Toast.makeText(MainActivity.this,
                        "Failed: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        };

        // Example: Set timezone to Seoul
        findViewById(R.id.btnSetSeoul).setOnClickListener(v -> {
            timeZoneController.setTimeZone("Asia/Seoul");
        });

        // Example: Set timezone to New York
        findViewById(R.id.btnSetNewYork).setOnClickListener(v -> {
            timeZoneController.setTimeZone("America/New_York");
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        timeZoneController.cleanup();
    }
}
```

##### Testing with ADB

You can test the timezone control feature from the terminal using ADB (Android Debug Bridge) commands.

###### Set Timezone (Asia/Seoul)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "timezone" --es timezone "Asia/Seoul"
```

###### Test Result Callback

```bash
# First, monitor the result in logcat
adb logcat | grep "TIMEZONE_RESULT"

# In another terminal, send the broadcast with the result action
adb shell am broadcast -a com.android.server.startupservice.system --es setting "timezone" --es timezone "America/New_York" --es timezone_result_action "com.test.TIMEZONE_RESULT"
```

###### Test Invalid Timezone (Error Case)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "timezone" --es timezone "InvalidTimeZone" --es timezone_result_action "com.test.TIMEZONE_RESULT"
```

---

#### 2.2.3 NTP Settings SDK

> **Note** <br>
> This feature is supported from StartUp version 6.4.9 and above.

##### Overview

This SDK allows external Android applications to control the device's NTP (Network Time Protocol) server settings through broadcast communication with the StartUp app.

**Important**: Changes take effect after device reboot.

**Supported Devices**: All M3 Mobile devices with StartUp app installed

###### Quick Start

**Basic Usage**

```java
// Set NTP server to Google's public NTP server
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","ntp");
intent.putExtra("ntp_server","time.google.com");

context.sendBroadcast(intent);
```

##### API Reference

###### Broadcast Action

**Action**: `com.android.server.startupservice.system`

###### Parameters

| Parameter    | Type   | Required | Description                                                            |
|--------------|--------|----------|------------------------------------------------------------------------|
| `setting`    | String | Yes      | Setting type. Use `"ntp"` for NTP server control.                      |
| `ntp_server` | String | Yes      | NTP server URL or IP address (e.g., "time.google.com", "pool.ntp.org") |

###### NTP Servers example

| Server Address        | Description                | Region |
|-----------------------|----------------------------|--------|
| `time.google.com`     | Google Public NTP          | Global |

##### Important Notes

###### 1. Reboot Required

The NTP server setting will take effect **after the next device reboot**. The system will display a
toast message:

```
"NTP server has been specified. It will take effect from the next boot."
```

###### 2. No Result Callback

Unlike timezone or USB settings, this API does not support result callbacks. The setting is
immediately saved to the system but requires a reboot to apply.

###### 3. Validation

- The API does not validate if the NTP server address is valid
- Make sure to provide a correct NTP server URL or IP address
- Invalid servers will not cause errors but may result in time sync failures

##### Full Example

###### Client App Implementation

```java
public class NtpController {
    private Context context;

    public NtpController(Context context) {
        this.context = context;
    }

    /**
     * Set NTP server
     * @param ntpServer NTP server URL or IP address (e.g., "time.google.com")
     */
    public void setNtpServer(String ntpServer) {
        if (ntpServer == null || ntpServer.trim().isEmpty()) {
            Log.e("NtpController", "NTP server cannot be empty");
            return;
        }

        // Send NTP setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "ntp");
        intent.putExtra("ntp_server", ntpServer);
        context.sendBroadcast(intent);

        Log.i("NtpController", "NTP server setting sent: " + ntpServer);
    }
}
```

###### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private NtpController ntpController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ntpController = new NtpController(this);

        // Example: Set NTP server to Google's public NTP
        findViewById(R.id.btnGoogleNtp).setOnClickListener(v -> {
            ntpController.setNtpServer("time.google.com");
            Toast.makeText(this,
                    "NTP server set to time.google.com\nReboot required to apply",
                    Toast.LENGTH_LONG).show();
        });

        // Example: Set NTP server to NTP Pool Project
        findViewById(R.id.btnPoolNtp).setOnClickListener(v -> {
            ntpController.setNtpServer("pool.ntp.org");
            Toast.makeText(this,
                    "NTP server set to pool.ntp.org\nReboot required to apply",
                    Toast.LENGTH_LONG).show();
        });

        // Example: Set custom NTP server
        findViewById(R.id.btnCustomNtp).setOnClickListener(v -> {
            EditText etCustomNtp = findViewById(R.id.etCustomNtp);
            String customServer = etCustomNtp.getText().toString().trim();

            if (!customServer.isEmpty()) {
                ntpController.setNtpServer(customServer);
                Toast.makeText(this,
                        "NTP server set to " + customServer + "\nReboot required to apply",
                        Toast.LENGTH_LONG).show();
            } else {
                Toast.makeText(this,
                        "Please enter a valid NTP server address",
                        Toast.LENGTH_SHORT).show();
            }
        });
    }
}
```


##### Testing with ADB

You can test the NTP server setting feature from the terminal using ADB (Android Debug Bridge)
commands.

###### Set NTP Server (Google)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "ntp" --es ntp_server "time.google.com"
```

###### Verify Setting (After Reboot)

```bash
# Check current NTP server setting
adb shell settings get global ntp_server
```

---

### 2.3 Wi-Fi Settings

---

#### 2.3.1 Captive Portal SDK

Controls the detection of captive portals (authentication pages) on public Wi-Fi networks.

> **Note** <br>
> Supported from StartUp version 6.0.6 BETA. <br>
> [Available on Android 11 and later](https://developer.android.com/about/versions/11/features/captive-portal),
> and is not supported on SL20 devices.

##### Broadcast Actions

###### Settings API

| Action                                         | Purpose                        | Features                               |
|------------------------------------------------|--------------------------------|----------------------------------------|
| `com.android.server.startupservice.config`     | Change Captive Portal settings | Saved in JSON, persists after reboot   |

---

##### API Details

###### Parameters

| Parameter | Type   | Value            | Description    |
|-----------|--------|------------------|----------------|
| `setting` | String | `captive_portal` | Settings Key   |
| `value`   | int    | `0`, `1`         | Enable/Disable |

###### Feature Description

| Value | Status    | Behavior                                                                        |
|-------|-----------|---------------------------------------------------------------------------------|
| `0`   | Disabled  | Does not detect captive portals; only performs a standard internet connection check. |
| `1`   | Enabled   | Automatically detects captive portals and provides a notification if login is required. |

###### Use Cases

- **Enabled (1)**: Environments with many public Wi-Fi networks like cafes, airports, and hotels.
- **Disabled (0)**: Environments where authentication is not required, such as corporate networks or home Wi-Fi.

###### Kotlin Code Example

```kotlin
// Enable Captive Portal Detection
fun enableCaptivePortalDetection(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "captive_portal")
        putExtra("value", 1) // Enable
    }
    context.sendBroadcast(intent)
}

// Disable Captive Portal Detection
fun disableCaptivePortalDetection(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "captive_portal")
        putExtra("value", 0) // Disable
    }
    context.sendBroadcast(intent)
}
```

###### ADB Command Example

```bash
# Enable Captive Portal
adb shell am broadcast -a com.android.server.startupservice.config --es setting "captive_portal" --ei value 1
```

```bash
# Disable Captive Portal
adb shell am broadcast -a com.android.server.startupservice.config --es setting "captive_portal" --ei value 0
```

###### Response Information

- **Response Format**: No separate response broadcast.
- **Monitoring**: Can be checked in System Settings > Network > Wi-Fi > Advanced.

---

#### 2.3.2 Open Network Notification SDK

> **Note** <br>
> Supported from StartUp version 6.0.6 BETA.

Controls the notification feature for detecting unsecured Wi-Fi networks.

##### Broadcast Actions

###### Settings API

| Action                                         | Purpose                                   |
|------------------------------------------------|-------------------------------------------|
| `com.android.server.startupservice.config`     | Change Open Network Notification settings |

---

##### API Details

###### Parameters

| Parameter | Type   | Value            | Description    |
|-----------|--------|------------------|----------------|
| `setting` | String | `wifi_open_noti` | Settings Key   |
| `value`   | int    | `0`, `1`         | Enable/Disable |

###### Feature Description

| Value | Status    | Behavior                                                              |
|-------|-----------|-----------------------------------------------------------------------|
| `0`   | Disabled  | Does not notify about detected Open Networks (unsecured).             |
| `1`   | Enabled   | Automatically detects and displays notifications for Open Networks.   |

###### Use Cases

- **Enabled (1)**: General user environments where raising security awareness is needed.
- **Disabled (0)**: Controlled environments (corporate/educational) where security settings are already configured.

###### Kotlin Code Example

```kotlin
// Enable Open Network Notification
fun enableOpenNetworkNotification(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_open_noti")
        putExtra("value", 1) // Enable
    }
    context.sendBroadcast(intent)
}

// Disable Open Network Notification
fun disableOpenNetworkNotification(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_open_noti")
        putExtra("value", 0) // Disable
    }
    context.sendBroadcast(intent)
}
```

###### ADB Command Example

```bash
# Enable Open Network Notification
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_open_noti" --ei value 1
```

```bash
# Disable Open Network Notification
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_open_noti" --ei value 0
```

###### Response Information

- **Response Format**: No separate response broadcast.
- **Notification Behavior**: Displays an "Open network available" notification in the system status bar.

---

#### 2.3.3 Sleep Policy SDK

> **Note** <br>
> Supported from StartUp version 6.0.6 BETA.

Controls the Wi-Fi behavior when the screen is off (standby mode).

##### Broadcast Actions

###### Settings API

| Action                                         | Purpose                            |
|------------------------------------------------|------------------------------------|
| `com.android.server.startupservice.config`     | Change Wi-Fi Sleep Policy settings |

---

##### API Details

###### Parameters

| Parameter | Type   | Value         | Description        |
|-----------|--------|---------------|--------------------|
| `setting` | String | `wifi_sleep`  | Settings Key       |
| `value`   | int    | `0`, `1`, `2` | Sleep Policy Mode  |

###### Sleep Policy Modes

| Value | Mode                 | Description                                                                    |
|-------|----------------------|--------------------------------------------------------------------------------|
| `0`   | Never                | Keeps Wi-Fi connection even when the screen is off (high battery consumption). |
| `1`   | Only when plugged in | Keeps Wi-Fi on only when plugged into an AC power source.                      |
| `2`   | Always               | Disables Wi-Fi when the screen turns off (saves battery).                      |

###### Kotlin Code Example

```kotlin
// Set Wi-Fi Sleep Policy - Never
fun setWifiSleepPolicyNever(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_sleep")
        putExtra("value", 0) // Never
    }
    context.sendBroadcast(intent)
}

// Set Wi-Fi Sleep Policy - Always
fun setWifiSleepPolicyAlways(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_sleep")
        putExtra("value", 2) // Always
    }
    context.sendBroadcast(intent)
}

// Set Wi-Fi Sleep Policy - Only when plugged in
fun setWifiSleepPolicyPluggedOnly(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_sleep")
        putExtra("value", 1) // Only when plugged in
    }
    context.sendBroadcast(intent)
}
```

###### ADB Command Example

```bash
# Keep Wi-Fi on always (Sleep Policy: Never)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_sleep" --ei value 0
```

```bash
# Keep Wi-Fi on only when plugged in (Sleep Policy: Only when plugged in)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_sleep" --ei value 1
```

```bash
# Disable Wi-Fi when screen is off (Sleep Policy: Always)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_sleep" --ei value 2
```

###### Response Information

- **Response Format**: No separate response broadcast.

---

#### 2.3.4 Stability SDK

Sets the stability level of the Wi-Fi connection. Controls the reconnection policy based on signal strength changes.

> **Note** <br>
> **Not compatible with Android 13 and higher** <br>
> Due to internal Wi-Fi policy changes starting from Android 13 (API 33), the stability settings via this SDK are no longer effective.

##### Broadcast Actions

###### Settings API

| Action                                         | Purpose                         |
|------------------------------------------------|---------------------------------|
| `com.android.server.startupservice.config`     | Change Wi-Fi Stability settings |

---

##### API Details

###### Parameters

| Parameter | Type   | Value            | Description     |
|-----------|--------|------------------|-----------------|
| `setting` | String | `wifi_stability` | Settings Key    |
| `value`   | int    | `1`, `2`         | Stability Mode  |

###### Stability Modes

| Value | Mode   | Description                                                                                               |
|-------|--------|-----------------------------------------------------------------------------------------------------------|
| `1`   | Normal | Normal Wi-Fi stability (occasionally reconnects when the signal is weak).                                 |
| `2`   | High   | High stability (tries to maintain the connection even with a weak signal, increased battery consumption). |

###### Kotlin Code Example

```kotlin
// Set Wi-Fi Stability - Normal Mode
fun setWifiStabilityNormal(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_stability")
        putExtra("value", 1) // Normal
    }
    context.sendBroadcast(intent)
}

// Set Wi-Fi Stability - High Stability
fun setWifiStabilityHigh(context: Context) {
    val intent = Intent("com.android.server.startupservice.config").apply {
        putExtra("setting", "wifi_stability")
        putExtra("value", 2) // High
    }
    context.sendBroadcast(intent)
}
```

###### ADB Command Example

```bash
# Set Wi-Fi Stability - Normal Mode
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_stability" --ei value 1
```

```bash
# Set Wi-Fi Stability - High Stability
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_stability" --ei value 2
```

###### Response Information

- **Response Format**: No separate response broadcast.

---

#### 2.3.5 Country Code SDK

> **Note** <br>
> Supported from StartUp version 6.0.6 BETA. <br>
> SL10 and SL10K devices are not supported.

##### Overview

This SDK allows external Android applications to set the device's Wi-Fi country code via broadcast communication with the StartUp app.

The Wi-Fi country code is a critical setting that ensures the device complies with the wireless regulations of the region where it is operating. Each country has different rules regarding permissible Wi-Fi channels and transmission power, making the correct country code essential.

###### Quick Start

**Basic Usage**

```java
// Set the Wi-Fi country code to South Korea ('KR')
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_country_code");
intent.putExtra("value", "KR");
context.sendBroadcast(intent);

// Set the Wi-Fi country code to the United States ('US')
Intent intentUS = new Intent("com.android.server.startupservice.config");
intentUS.putExtra("setting", "wifi_country_code");
intentUS.putExtra("value", "US");
context.sendBroadcast(intentUS);
```

##### API Reference

###### Broadcast Action

**Action**: `com.android.server.startupservice.config`

###### Parameters

| Parameter | Type   | Required | Description                                               |
|-----------|--------|----------|-----------------------------------------------------------|
| `setting` | String | Yes      | Must be set to `"wifi_country_code"`.                     |
| `value`   | String | Yes      | An ISO 3166-1 alpha-2 two-letter country code (e.g., "KR", "US", "JP"). |

---

##### Detailed Configuration Guide

###### Wi-Fi Country Code

Sets the Wi-Fi country code to comply with the regulations of the operating region.

-   **`setting` value**: `"wifi_country_code"`
-   **`value` type**: `String`
-   **`value` description**: An ISO 3166-1 alpha-2 two-letter country code.

###### Example Country Codes

| Code | Country       | Description                               |
|------|---------------|-------------------------------------------|
| `KR` | South Korea   | Complies with South Korean Wi-Fi regulations. |
| `US` | United States | Complies with US Wi-Fi regulations.       |
| `JP` | Japan         | Complies with Japanese Wi-Fi regulations.   |
| `CN` | China         | Complies with Chinese Wi-Fi regulations.    |
| `EU` | European Union| Generic code for EU compliance.           |
| `GB` | United Kingdom| Complies with UK Wi-Fi regulations.         |
| `AU` | Australia     | Complies with Australian Wi-Fi regulations. |
| `CA` | Canada        | Complies with Canadian Wi-Fi regulations.   |

**Note**: For a complete list of ISO 3166-1 country codes, refer to the [official ISO website](https://www.iso.org/iso-3166-country-codes.html).

---

##### Full Example

###### Client App Implementation

```java
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import java.util.Locale;

public class WifiCountryCodeController {
    private Context context;

    public WifiCountryCodeController(Context context) {
        this.context = context;
    }

    /**
     * Sets the Wi-Fi country code.
     *
     * @param countryCode An ISO 3166-1 alpha-2 country code (e.g., "KR", "US").
     */
    public void setCountryCode(String countryCode) {
        if (!isValidCountryCode(countryCode)) {
            Log.e("WifiCountryCodeController", "Invalid country code: " + countryCode);
            return;
        }

        String upperCountryCode = countryCode.toUpperCase();

        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_country_code");
        intent.putExtra("value", upperCountryCode);
        context.sendBroadcast(intent);

        Log.i("WifiCountryCodeController", "Wi-Fi country code set to: " + upperCountryCode);
    }

    /**
     * Validates if the country code is a two-letter ISO 3166-1 format.
     */
    private boolean isValidCountryCode(String countryCode) {
        if (countryCode == null || countryCode.isEmpty()) {
            return false;
        }
        return countryCode.length() == 2 && countryCode.matches("[a-zA-Z]{2}");
    }

    /**
     * Retrieves the current system country code.
     */
    public String getSystemCountryCode() {
        return Locale.getDefault().getCountry();
    }
}
```

---

##### Testing with ADB

###### Set Wi-Fi Country Code

```bash
# Set country code to South Korea
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_country_code" --es value "KR"
```

```bash
# Set country code to the United States
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_country_code" --es value "US"
```

---

##### Important Notes

1.  **Valid Country Codes**: Only use ISO 3166-1 alpha-2 two-letter country codes.
2.  **Case Insensitive**: Country codes are typically uppercase, but the SDK handles conversion automatically.
3.  **Legal Compliance**: You are responsible for setting the correct country code for the region where the device is operating to comply with local laws.
4.  **Restart May Be Required**: On some devices, a Wi-Fi toggle (off/on) or a full device restart may be necessary for the changes to take full effect.

---

#### 2.3.6 Frequency Band SDK

> **Note** <br>
> Supported from StartUp version 6.0.6 BETA. <br>
> SL10 and SL10K devices are not supported.

##### Overview

This SDK allows external Android applications to restrict device Wi-Fi scanning and connection to specific frequency bands (2.4GHz or 5GHz) through broadcast communication with the StartUp app.

By restricting frequency bands, the device will only scan and connect to APs on the specified band, enabling optimized Wi-Fi settings for your network environment.

Supported frequency bands:
- **AUTO (0)**: Use both 2.4GHz + 5GHz (default)
- **5GHz only (1)**: Scan and connect only to 5GHz band
- **2.4GHz only (2)**: Scan and connect only to 2.4GHz band

###### Quick Start

**Basic Usage**

```java
// AUTO mode (use both 2.4GHz + 5GHz)
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 0);
context.sendBroadcast(intent);

// 5GHz only
Intent intent5G = new Intent("com.android.server.startupservice.config");
intent5G.putExtra("setting", "wifi_freq_band");
intent5G.putExtra("value", 1);
context.sendBroadcast(intent5G);

// 2.4GHz only
Intent intent24G = new Intent("com.android.server.startupservice.config");
intent24G.putExtra("setting", "wifi_freq_band");
intent24G.putExtra("value", 2);
context.sendBroadcast(intent24G);
```

##### API Reference

###### Broadcast Action

**Action**: `com.android.server.startupservice.config`

###### Parameters

| Parameter | Type   | Required | Description                                                                          |
|-----------|--------|----------|--------------------------------------------------------------------------------------|
| `setting` | String | Yes      | Must be set to `"wifi_freq_band"`.                                                   |
| `value`   | int    | Yes      | Frequency band setting value<br>0: AUTO (2.4GHz + 5GHz)<br>1: 5GHz only<br>2: 2.4GHz only |

---

##### Detailed Configuration Guide

###### Frequency Band Options

**AUTO (0) - Dual Band**
- Both 2.4GHz and 5GHz available
- Device automatically selects optimal band
- Recommended default for most environments

**5GHz only (1)**
- Scan and connect only to 5GHz band
- Faster speeds and less interference
- Recommended for environments with 5GHz APs
- Advantages: High bandwidth, less interference
- Disadvantages: Shorter range

**2.4GHz only (2)**
- Scan and connect only to 2.4GHz band
- Wider coverage
- Use in environments with only 2.4GHz APs
- Advantages: Wide coverage, better obstacle penetration
- Disadvantages: Higher interference potential, relatively lower speeds

---

##### Common Use Cases

###### Scenario 1: Warehouse/Logistics Center (2.4GHz only)

Large spaces with many obstacles:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 2); // 2.4GHz only
context.sendBroadcast(intent);
```

###### Scenario 2: Office/High-Speed Data Transfer (5GHz only)

Low interference environment requiring high-speed communication:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 1); // 5GHz only
context.sendBroadcast(intent);
```

###### Scenario 3: General Environment (AUTO)

Various environments:

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_freq_band");
intent.putExtra("value", 0); // AUTO
context.sendBroadcast(intent);
```

---

##### Integration with wifi-channel-sdk

The wifi-frequency-sdk controls entire frequency bands (2.4GHz/5GHz), while the wifi-channel-sdk provides fine-grained control over specific channels within each band.

For more granular control, you can use both SDKs together:

###### Integration Examples

**Example: Use only non-overlapping channels (1, 6, 11) in 2.4GHz band**

```java
// Step 1: Restrict frequency band to 2.4GHz
Intent freqIntent = new Intent("com.android.server.startupservice.config");
freqIntent.putExtra("setting", "wifi_freq_band");
freqIntent.putExtra("value", 2); // 2.4GHz only
context.sendBroadcast(freqIntent);

// Step 2: Use only channels 1, 6, 11 within 2.4GHz band
Intent channelIntent = new Intent("com.android.server.startupservice.config");
channelIntent.putExtra("setting", "wifi_channel");
String[] channels = {"1", "6", "11"};
channelIntent.putExtra("value", channels);
context.sendBroadcast(channelIntent);
```

**Example: Use only non-DFS channels in 5GHz band**

```java
// Step 1: Restrict frequency band to 5GHz
Intent freqIntent = new Intent("com.android.server.startupservice.config");
freqIntent.putExtra("setting", "wifi_freq_band");
freqIntent.putExtra("value", 1); // 5GHz only
context.sendBroadcast(freqIntent);

// Step 2: Use only non-DFS channels within 5GHz band
Intent channelIntent = new Intent("com.android.server.startupservice.config");
channelIntent.putExtra("setting", "wifi_channel");
String[] channels = {"36", "40", "44", "48", "149", "153", "157", "161", "165"};
channelIntent.putExtra("value", channels);
context.sendBroadcast(channelIntent);
```

**Note**: For more details on wifi-channel-sdk, see the [Wi-Fi Channel Setting SDK Documentation](wifi-channel-sdk-readme.md).

---

##### Complete Examples

###### Client App Implementation

```java
public class WifiFrequencyController {
    private Context context;

    public WifiFrequencyController(Context context) {
        this.context = context;
    }

    /**
     * Set Wi-Fi frequency band
     *
     * @param band Frequency band (0: AUTO, 1: 5GHz, 2: 2.4GHz)
     */
    public void setWifiFrequencyBand(int band) {
        // Validate value
        if (band < 0 || band > 2) {
            Log.e("WifiFrequencyController", "Invalid band value: " + band);
            return;
        }

        // Send Wi-Fi frequency band setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_freq_band");
        intent.putExtra("value", band);
        context.sendBroadcast(intent);

        String bandName = getBandName(band);
        Log.i("WifiFrequencyController", "Wi-Fi frequency band set to: " + bandName);
    }

    /**
     * Set AUTO mode (2.4GHz + 5GHz)
     */
    public void setAuto() {
        setWifiFrequencyBand(0);
    }

    /**
     * Use 5GHz only
     */
    public void set5GHzOnly() {
        setWifiFrequencyBand(1);
    }

    /**
     * Use 2.4GHz only
     */
    public void set24GHzOnly() {
        setWifiFrequencyBand(2);
    }

    /**
     * Get band name
     */
    private String getBandName(int band) {
        switch (band) {
            case 0:
                return "AUTO (2.4GHz + 5GHz)";
            case 1:
                return "5GHz only";
            case 2:
                return "2.4GHz only";
            default:
                return "Unknown";
        }
    }
}
```

###### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private WifiFrequencyController wifiFrequencyController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        wifiFrequencyController = new WifiFrequencyController(this);

        // AUTO mode
        findViewById(R.id.btnSetAuto).setOnClickListener(v -> {
            wifiFrequencyController.setAuto();
            Toast.makeText(this, "AUTO mode set (2.4GHz + 5GHz)", Toast.LENGTH_SHORT).show();
        });

        // 5GHz only
        findViewById(R.id.btnSet5GHzOnly).setOnClickListener(v -> {
            wifiFrequencyController.set5GHzOnly();
            Toast.makeText(this, "5GHz only mode set", Toast.LENGTH_SHORT).show();
        });

        // 2.4GHz only
        findViewById(R.id.btnSet24GHzOnly).setOnClickListener(v -> {
            wifiFrequencyController.set24GHzOnly();
            Toast.makeText(this, "2.4GHz only mode set", Toast.LENGTH_SHORT).show();
        });
    }
}
```

###### Kotlin Usage

```kotlin
class WifiFrequencyController(private val context: Context) {

    /**
     * Set Wi-Fi frequency band
     */
    fun setWifiFrequencyBand(band: Int) {
        // Validate value
        if (band !in 0..2) {
            Log.e("WifiFrequencyController", "Invalid band value: $band")
            return
        }

        // Send Wi-Fi frequency band setting broadcast
        Intent("com.android.server.startupservice.config").apply {
            putExtra("setting", "wifi_freq_band")
            putExtra("value", band)
            context.sendBroadcast(this)
        }

        Log.i("WifiFrequencyController", "Wi-Fi frequency band set to: ${getBandName(band)}")
    }

    /**
     * Set AUTO mode (2.4GHz + 5GHz)
     */
    fun setAuto() = setWifiFrequencyBand(0)

    /**
     * Use 5GHz only
     */
    fun set5GHzOnly() = setWifiFrequencyBand(1)

    /**
     * Use 2.4GHz only
     */
    fun set24GHzOnly() = setWifiFrequencyBand(2)

    /**
     * Get band name
     */
    private fun getBandName(band: Int): String = when (band) {
        0 -> "AUTO (2.4GHz + 5GHz)"
        1 -> "5GHz only"
        2 -> "2.4GHz only"
        else -> "Unknown"
    }
}

// Kotlin Activity usage example
class MainActivity : AppCompatActivity() {
    private lateinit var wifiFrequencyController: WifiFrequencyController

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        wifiFrequencyController = WifiFrequencyController(this)

        // AUTO mode
        findViewById<Button>(R.id.btnSetAuto).setOnClickListener {
            wifiFrequencyController.setAuto()
            Toast.makeText(this, "AUTO mode set", Toast.LENGTH_SHORT).show()
        }

        // 5GHz only
        findViewById<Button>(R.id.btnSet5GHzOnly).setOnClickListener {
            wifiFrequencyController.set5GHzOnly()
            Toast.makeText(this, "5GHz only mode set", Toast.LENGTH_SHORT).show()
        }

        // 2.4GHz only
        findViewById<Button>(R.id.btnSet24GHzOnly).setOnClickListener {
            wifiFrequencyController.set24GHzOnly()
            Toast.makeText(this, "2.4GHz only mode set", Toast.LENGTH_SHORT).show()
        }
    }
}
```

---

##### Testing with ADB

###### AUTO mode (2.4GHz + 5GHz)

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 0
```

###### 5GHz only

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 1
```

###### 2.4GHz only

```bash
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_freq_band" --ei value 2
```

---

##### Important Notes

1. **Reconnection Required**: After changing frequency band settings, you may need to toggle Wi-Fi or restart the device for the settings to fully take effect.

2. **Network Environment Considerations**:
   - When set to 5GHz only mode, connection is not possible in environments with only 2.4GHz APs
   - When set to 2.4GHz only mode, connection is not possible in environments with only 5GHz APs

3. **Device-Specific Implementations**: Some devices may have different internal implementations, but the SDK usage method is the same.

4. **Use with wifi-channel-sdk**: For more granular channel control, you can use this SDK together with wifi-channel-sdk.

5. **Default Value**: If not configured, AUTO mode (0) is the default.

---

#### 2.3.7 Channel SDK

> **Note** <br>
> Supported from StartUp version 6.0.6 BETA. <br>
> Not supported on SM15, SL10, SL10K devices.

##### Overview

This SDK allows external Android applications to restrict the device's Wi-Fi scanning and connection to specific channels through broadcast communication with the StartUp app.

By limiting Wi-Fi channels, the device will only scan for and connect to Access Points (APs) on the specified channels. This can improve connection speed by avoiding congested channels or be used to enforce specific network policies.

Supported Channels:
- **2.4 GHz Band**: Channels 1 - 13
- **5 GHz Band**: Channels 36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144, 149, 153, 157, 161, 165

###### Quick Start

**Basic Usage**

```java
// Restrict Wi-Fi channels to 1, 6, 11 (2.4GHz) and 36, 40 (5GHz)
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_channel");
String[] channels = {"1", "6", "11", "36", "40"};
intent.putExtra("value", channels);
context.sendBroadcast(intent);

// Use only 2.4GHz channels (1, 6, 11)
Intent intent24 = new Intent("com.android.server.startupservice.config");
intent24.putExtra("setting", "wifi_channel");
String[] channels24 = {"1", "6", "11"};
intent24.putExtra("value", channels24);
context.sendBroadcast(intent24);

// Use only 5GHz channels (36, 40, 149, 153)
Intent intent5 = new Intent("com.android.server.startupservice.config");
intent5.putExtra("setting", "wifi_channel");
String[] channels5 = {"36", "40", "149", "153"};
intent5.putExtra("value", channels5);
context.sendBroadcast(intent5);
```

##### API Reference

###### Broadcast Action

**Action**: `com.android.server.startupservice.config`

###### Parameters

| Parameter | Type     | Required | Description                                                                   |
|-----------|----------|----------|-------------------------------------------------------------------------------|
| `setting` | String   | Yes      | Must be set to `"wifi_channel"`.                                              |
| `value`   | String[] | Yes      | A string array of Wi-Fi channel numbers to enable (e.g., `{"1", "6", "11"}`). |

---

##### Detailed Configuration Guide

###### Restricting Wi-Fi Channels

This setting limits Wi-Fi scanning and connections to a specific list of channels. You can specify both 2.4 GHz and 5 GHz channels simultaneously.

-   **`setting` value**: `"wifi_channel"`
-   **`value` type**: `String[]` (String array)
-   **`value` description**: A list of channel numbers to activate.

###### 2.4 GHz Channels (Channels 1 - 14)

| Channel | Center Frequency | Region       | Notes                                 |
|---------|------------------|--------------|---------------------------------------|
| 1       | 2412 MHz         | Worldwide    | Non-overlapping channel (Recommended) |
| 2       | 2417 MHz         | Worldwide    |                                       |
| 3       | 2422 MHz         | Worldwide    |                                       |
| 4       | 2427 MHz         | Worldwide    |                                       |
| 5       | 2432 MHz         | Worldwide    |                                       |
| 6       | 2437 MHz         | Worldwide    | Non-overlapping channel (Recommended) |
| 7       | 2442 MHz         | Worldwide    |                                       |
| 8       | 2447 MHz         | Worldwide    |                                       |
| 9       | 2452 MHz         | Worldwide    |                                       |
| 10      | 2457 MHz         | Worldwide    |                                       |
| 11      | 2462 MHz         | Worldwide    | Non-overlapping channel (Recommended) |
| 12      | 2467 MHz         | Europe, Asia |                                       |
| 13      | 2472 MHz         | Europe, Asia |                                       |
| 14      | 2484 MHz         | Japan only   | Special channel (802.11b only)        |

**2.4 GHz Channel Selection Guide**:
- **Non-overlapping Channels (1, 6, 11)**: Recommended combination to minimize interference.
- **Channels 12, 13**: Available only in certain countries (requires correct country code setting).
- **Channel 14**: Available only in Japan and is exclusive to 802.11b.

###### 5 GHz Channels

The 5 GHz band offers more channels and is generally less congested.

**UNII-1 (Indoor, Low Power)**

| Channel | Center Frequency | Bandwidth |
|---------|------------------|-----------|
| 36      | 5180 MHz         | 20 MHz    |
| 40      | 5200 MHz         | 20 MHz    |
| 44      | 5220 MHz         | 20 MHz    |
| 48      | 5240 MHz         | 20 MHz    |

**UNII-2 (DFS Required)**

| Channel | Center Frequency | Bandwidth | Notes       |
|---------|------------------|-----------|-------------|
| 52      | 5260 MHz         | 20 MHz    | DFS Channel |
| 56      | 5280 MHz         | 20 MHz    | DFS Channel |
| 60      | 5300 MHz         | 20 MHz    | DFS Channel |
| 64      | 5320 MHz         | 20 MHz    | DFS Channel |
| 100     | 5500 MHz         | 20 MHz    | DFS Channel |
| ...     | ...              | ...       | ...         |
| 144     | 5720 MHz         | 20 MHz    | DFS Channel |

**UNII-3 (Outdoor, High Power)**

| Channel | Center Frequency | Bandwidth | Notes                 |
|---------|------------------|-----------|-----------------------|
| 149     | 5745 MHz         | 20 MHz    | Non-DFS (Recommended) |
| 153     | 5765 MHz         | 20 MHz    | Non-DFS (Recommended) |
| 157     | 5785 MHz         | 20 MHz    | Non-DFS (Recommended) |
| 161     | 5805 MHz         | 20 MHz    | Non-DFS (Recommended) |
| 165     | 5825 MHz         | 20 MHz    | Non-DFS (Recommended) |

**5 GHz Channel Selection Guide**:
- **Recommended Non-DFS Channels**: 36, 40, 44, 48, 149, 153, 157, 161, 165.
  - These channels do not require DFS (Dynamic Frequency Selection), leading to faster and more stable connections.
- **DFS Channels**: Channels in the 52-144 range.
  - These channels require a DFS scan (can take over a minute) before use and may switch automatically if radar signals are detected, causing temporary disconnections.

---

##### Common Use Cases

###### Scenario 1: Use Only 2.4 GHz Non-overlapping Channels

To minimize interference, use only the non-overlapping 2.4 GHz channels (1, 6, 11).

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_channel");
String[] channels = {"1", "6", "11"};
intent.putExtra("value", channels);
context.sendBroadcast(intent);
```

###### Scenario 2: Use Only 5 GHz Non-DFS Channels

For fast and stable connections, use only the 5 GHz Non-DFS channels.

```java
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting", "wifi_channel");
String[] channels = {"36", "40", "44", "48", "149", "153", "157", "161", "165"};
intent.putExtra("value", channels);
context.sendBroadcast(intent);
```

---

##### Full Example

###### Client App Implementation

```java
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import java.util.Arrays;

public class WifiChannelController {
    private Context context;

    public WifiChannelController(Context context) {
        this.context = context;
    }

    /**
     * Set allowed Wi-Fi channels.
     *
     * @param channels An array of channel numbers to enable (e.g., {"1", "6", "149"}).
     */
    public void setWifiChannels(String[] channels) {
        for (String channel : channels) {
            if (!isValidChannel(channel)) {
                Log.e("WifiChannelController", "Invalid channel detected: " + channel);
                return;
            }
        }

        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", "wifi_channel");
        intent.putExtra("value", channels);
        context.sendBroadcast(intent);

        Log.i("WifiChannelController", "Wi-Fi channels set to: " + Arrays.toString(channels));
    }

    /**
     * Clears all channel restrictions by sending an empty array.
     */
    public void clearChannelRestrictions() {
        setWifiChannels(new String[]{});
    }

    private boolean isValidChannel(String channel) {
        try {
            int ch = Integer.parseInt(channel);
            if (ch >= 1 && ch <= 14) return true; // 2.4 GHz
            int[] valid5GHz = {36, 40, 44, 48, 52, 56, 60, 64, 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144, 149, 153, 157, 161, 165};
            for (int validCh : valid5GHz) {
                if (ch == validCh) return true;
            }
            return false;
        } catch (NumberFormatException e) {
            return false;
        }
    }
}
```

---

##### Testing with ADB

###### Set 2.4 GHz Channels

```bash
# Set non-overlapping channels (1, 6, 11)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "1,6,11"
```

###### Set 5 GHz Channels

```bash
# Set 5GHz Non-DFS channels
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value "36,40,44,48,149,153,157,161,165"
```

###### Clear Restrictions

```bash
# Send an empty array to clear all channel restrictions
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_channel" --esa value ""
```

---

##### Important Notes

1.  **Country Code**: The availability of Wi-Fi channels depends on the device's country code setting. Ensure the correct country code is set before configuring channels.
2.  **Empty Array**: Sending an empty array for the `value` parameter will remove all channel restrictions, enabling all available channels.
3.  **Invalid Channels**: If an unsupported channel number is included in the array, it will be ignored.
4.  **DFS Channels**: Channels in the 52-144 range require DFS scans, which can delay connection and are not recommended for time-sensitive applications.
5.  **Restart Required**: After changing the channel configuration, toggling Wi-Fi off and on or restarting the device may be necessary for the settings to take full effect.
6.  **ADB Array Format**: When using ADB, pass string arrays with the `--esa` flag and separate values with a comma (no spaces).

---

#### 2.3.8 Roaming SDK

> **Note** <br>
> Supported from StartUp version 6.0.6 BETA. <br>
> SL10 and SL10K devices are not supported.

##### Overview

This SDK allows external Android applications to control the device's Wi-Fi roaming behavior through broadcast communication with the StartUp app.

Wi-Fi roaming is the process by which a device automatically switches from its currently connected Access Point (AP) to another AP that offers a stronger signal. This SDK provides control over two key parameters that govern this behavior:

-   **Roaming Trigger**: The RSSI threshold at which the device starts scanning for a new AP.
-   **Roaming Delta**: The minimum signal strength difference required for the device to switch to a new AP.

These two settings work together to define the device's roaming policy.

###### Quick Start

**Basic Usage**

```java
// Set the Roaming Trigger to index 1 (-75 dBm)
Intent intentTrigger = new Intent("com.android.server.startupservice.config");
intentTrigger.putExtra("setting", "wifi_roam_trigger");
intentTrigger.putExtra("value", "1");
context.sendBroadcast(intentTrigger);

// Set the Roaming Delta to index 4 (10 dB)
Intent intentDelta = new Intent("com.android.server.startupservice.config");
intentDelta.putExtra("setting", "wifi_roam_delta");
intentDelta.putExtra("value", "4");
context.sendBroadcast(intentDelta);
```

##### API Reference

###### Broadcast Action

**Action**: `com.android.server.startupservice.config`

###### Parameters

| Parameter | Type   | Required | Description                                                                          |
|-----------|--------|----------|--------------------------------------------------------------------------------------|
| `setting` | String | Yes      | The type of roaming setting to change: `"wifi_roam_trigger"` or `"wifi_roam_delta"`. |
| `value`   | int    | Yes      | The configuration value (integer index).                                             |

---

##### Detailed Configuration Guide

###### 1. Roaming Trigger (Minimum Wi-Fi Signal Strength)

This setting prevents the device from attempting to connect to APs with a signal strength (RSSI) at or below a certain threshold. It effectively defines when to start looking for a better connection.

-   **`setting` value**: `"wifi_roam_trigger"`
-   **`value` type**: `int` (index)
-   **`value` options**:

| Index | RSSI Threshold | Description                                    | Use Case                                  |
|-------|----------------|------------------------------------------------|-------------------------------------------|
| `0`   | -80 dBm        | Maintain connection until signal is very weak. | Prioritizing connection stability.        |
| `1`   | -75 dBm        | Actively find a new AP when signal weakens.    | Environments with many APs; fast roaming. |
| `2`   | -70 dBm        | Moderate roaming behavior (Recommended).       | General use cases.                        |
| `3`   | -65 dBm        | Start roaming when signal is slightly weak.    | Prioritizing signal quality.              |
| `4`   | -60 dBm        | Only maintain very strong signal connections.  | When only the best signal is acceptable.  |

**Understanding RSSI**:
-   RSSI (Received Signal Strength Indicator) is measured in dBm.
-   Values closer to 0 indicate a stronger signal.
-   -60 dBm: Excellent signal
-   -70 dBm: Good signal
-   -80 dBm: Fair signal

###### 2. Roaming Delta

The device will only switch to a new AP if its signal strength is greater than the current AP's signal by at least this delta.

-   **`setting` value**: `"wifi_roam_delta"`
-   **`value` type**: `int` (index)
-   **`value` options**:

| Index | Signal Strength Difference | Description                                  | Use Case                                      |
|-------|----------------------------|----------------------------------------------|-----------------------------------------------|
| `0`   | 30 dB                      | Roam only when the new signal is much better. | Extremely stable connection required.         |
| `1`   | 25 dB                      | Roam only for a large signal improvement.    | Minimizing roaming frequency.                 |
| `2`   | 20 dB                      | Roam for a significant improvement.          | Balance between stability and quality.        |
| `3`   | 15 dB                      | Roam for a moderate improvement.             | General environments.                         |
| `4`   | 10 dB                      | Roam for a reasonable improvement (Recommended).| Balanced roaming behavior.                  |
| `5`   | 5 dB                       | Roam even for a small improvement.           | Always maintain the best connection quality.  |
| `6`   | 0 dB                       | Roam to any AP with a better signal.         | Hyper-aggressive roaming (not recommended).   |

---

##### Roaming Policy Combination Guide

It is crucial to select the right combination of Roaming Trigger and Roaming Delta for your specific use case.

###### Recommended Combinations

| Scenario               | Trigger Index | Delta Index | Trigger Value | Delta Value | Description                                   |
|------------------------|---------------|-------------|---------------|-------------|-----------------------------------------------|
| **Aggressive Roaming** | 1             | 5           | -75 dBm       | 5 dB        | Quickly switch to a better AP.                |
| **Moderate (Default)** | 2             | 4           | -70 dBm       | 10 dB       | Balanced roaming behavior.                    |
| **Conservative**       | 0             | 3           | -80 dBm       | 15 dB       | Minimize unnecessary roaming.                 |

---

##### Full Example

###### Client App Implementation

```java
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class WifiRoamingController {
    private Context context;

    public WifiRoamingController(Context context) {
        this.context = context;
    }

    /**
     * Sets the Roaming Trigger.
     *
     * @param triggerIndex Index (0: -80dBm, 1: -75dBm, 2: -70dBm, 3: -65dBm, 4: -60dBm)
     */
    public void setRoamTrigger(int triggerIndex) {
        if (triggerIndex < 0 || triggerIndex > 4) {
            Log.e("WifiRoamingController", "Invalid roam trigger index: " + triggerIndex);
            return;
        }
        setRoamingValue("wifi_roam_trigger", triggerIndex);
    }

    /**
     * Sets the Roaming Delta.
     *
     * @param deltaIndex Index (0: 30dB, 1: 25dB, ..., 6: 0dB)
     */
    public void setRoamDelta(int deltaIndex) {
        if (deltaIndex < 0 || deltaIndex > 6) {
            Log.e("WifiRoamingController", "Invalid roam delta index: " + deltaIndex);
            return;
        }
        setRoamingValue("wifi_roam_delta", deltaIndex);
    }

    private void setRoamingValue(String setting, int value) {
        Intent intent = new Intent("com.android.server.startupservice.config");
        intent.putExtra("setting", setting);
        intent.putExtra("value", String.valueOf(value));
        context.sendBroadcast(intent);
        Log.i("WifiRoamingController", setting + " set to index: " + value);
    }

    public void setAggressiveRoaming() {
        setRoamTrigger(1);
        setRoamDelta(5);
    }
}
```

---

##### Testing with ADB

###### Set Individual Parameters

```bash
# Set Roaming Trigger to index 1 (-75dBm)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 1

# Set Roaming Delta to index 5 (5dB)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 5
```

###### Apply a Recommended Combination

```bash
# Apply Aggressive Roaming policy
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_trigger" --es value 1
adb shell am broadcast -a com.android.server.startupservice.config --es setting "wifi_roam_delta" --es value 5
```

---

##### Important Notes

1.  **Independent Settings**: Trigger and Delta can be set independently, but they should be configured together to achieve the desired roaming behavior.
2.  **Default Values**: If not configured, system defaults will be used. The "Moderate" policy (Trigger=2, Delta=4) is the recommended starting point.
3.  **Validation**: The SDK will ignore values that are outside the valid index range for each parameter.
4.  **Testing**: Always test the roaming behavior in a real-world environment to ensure it meets your requirements.

---

### 2.4 System Settings

---

#### 2.4.1 Airplane Mode SDK

> **Note** <br>
> This feature is supported from StartUp version 5.3.4 and above.

##### Overview

This SDK allows external Android applications to turn the device's Airplane Mode on or off through broadcast communication with the StartUp app.

###### Quick Start

**Basic Usage**

```java
// Enable Airplane Mode
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting", "airplane");
intent.putExtra("airplane", true); // true: on, false: off
context.sendBroadcast(intent);
```

##### API Reference

###### Broadcast Action

**Action**: `com.android.server.startupservice.system`

###### Parameters

| Parameter  | Type    | Required | Description                                                |
|------------|---------|----------|------------------------------------------------------------|
| `setting`  | String  | Yes      | Setting type. Use `"airplane"` for Airplane Mode control.  |
| `airplane` | boolean | Yes      | Airplane Mode state. `true` to enable, `false` to disable. |

##### Important Notes

###### 1. Immediate Effect

This setting is applied to the system as soon as the broadcast is sent.

##### Full Example

###### Client App Implementation

```java
public class AirplaneModeController {
    private Context context;

    public AirplaneModeController(Context context) {
        this.context = context;
    }

    /**
     * Sets the state of Airplane Mode.
     * @param enable true to enable, false to disable.
     */
    public void setAirplaneMode(boolean enable) {
        // Send Airplane Mode setting broadcast
        Intent intent = new Intent("com.android.server.startupservice.system");
        intent.putExtra("setting", "airplane");
        intent.putExtra("airplane", enable);
        context.sendBroadcast(intent);

        Log.i("AirplaneModeController", "Airplane Mode setting sent: " + enable);
    }
}
```

###### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private AirplaneModeController airplaneModeController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        airplaneModeController = new AirplaneModeController(this);

        // Example: Turn Airplane Mode On
        findViewById(R.id.btnAirplaneOn).setOnClickListener(v -> {
            airplaneModeController.setAirplaneMode(true);
            Toast.makeText(this, "Airplane Mode ON", Toast.LENGTH_SHORT).show();
        });

        // Example: Turn Airplane Mode Off
        findViewById(R.id.btnAirplaneOff).setOnClickListener(v -> {
            airplaneModeController.setAirplaneMode(false);
            Toast.makeText(this, "Airplane Mode OFF", Toast.LENGTH_SHORT).show();
        });
    }
}
```

##### Testing with ADB

You can test the Airplane Mode setting feature from the terminal using ADB (Android Debug Bridge) commands.

###### Turn Airplane Mode On

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "airplane" --ez airplane true
```

###### Turn Airplane Mode Off

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "airplane" --ez airplane false
```

###### Verify Setting

The Airplane Mode status can be visually confirmed via the device's status bar or Settings menu. Alternatively, you can check the system setting with the following command:

```bash
# '1' means on, '0' means off.
adb shell settings get global airplane_mode_on
```

---

#### 2.4.2 USB Settings SDK

> **Note** <br>
> This feature is supported from StartUp version 6.5.10 onwards. <br>
> Supported on US20 (Android 10), US30 (Android 13) devices.

##### Overview

This SDK allows external Android applications to control the device's USB mode settings through broadcast communication with the StartUp app.
It provides privileged access to system settings.

###### Quick Start

**Basic Usage**

```java
// Set USB mode to "No data transfer"
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","usb_setting");
intent.putExtra("usb_mode","none");

context.sendBroadcast(intent);
```

**Using Result Callback**

```java
// Send USB setting and receive result
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","usb_setting");
intent.putExtra("usb_mode","mtp");
// The value for "usb_result_action" can be any custom string you want.
intent.putExtra("usb_result_action","com.example.myapp.USB_RESULT");

context.sendBroadcast(intent);
```

##### API Reference

###### Broadcast Action

**Action**: `com.android.server.startupservice.system`

###### Parameters

| Parameter           | Type   | Required | Description                                        |
|---------------------|--------|----------|----------------------------------------------------|
| `setting`           | String | Yes      | Setting type. Use `"usb_setting"` for USB control. |
| `usb_mode`          | String | Yes      | USB mode: one of "mtp", "midi", "ptp", "none".     |
| `usb_result_action` | String | No       | Custom action for the result callback broadcast.   |

###### USB Modes

| Mode Value | Description            | Use Case                             |
|------------|------------------------|--------------------------------------|
| `mtp`      | File Transfer (MTP)    | File transfer (default file manager) |
| `rndis`    | USB tethering          | Share internet connection            |
| `midi`     | MIDI                   | Connect musical instruments          |
| `ptp`      | PTP (Picture Transfer) | Transfer photos                      |
| `none`     | No data transfer       | Charging only (no data transfer)     |

###### Result Callback

If you provide the `usb_result_action` parameter, the StartUp app will send a result broadcast:

**Action**: Custom action string (e.g., `com.example.myapp.USB_RESULT`)

**Result Parameters**:

| Parameter           | Type    | Description                                                 |
|---------------------|---------|-------------------------------------------------------------|
| `usb_success`       | boolean | `true` if the operation was successful, `false` otherwise.  |
| `usb_error_message` | String  | Error description (only present if `usb_success` is false). |

##### Error Handling

###### Error Scenarios

1.  **Invalid USB Mode**
    ```
    Error: "Invalid USB mode: invalid_mode. Valid modes are: mtp, midi, ptp, none"
    ```
    **Solution**: Use a valid USB mode (mtp, midi, ptp, none).

2.  **Unsupported Android Version**
    ```
    Error: "USB mode control requires Android 10 or higher"
    ```
    **Solution**: Requires Android 10 (API 29) or higher.

3.  **System Error**
    ```
    Error: "Failed to apply USB setting: [system error details]"
    ```
    **Solution**: Check system permissions and device status.

##### Full Example

###### Client App Implementation

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

###### Usage in Activity

```java
public class MainActivity extends AppCompatActivity {
    private UsbController usbController;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        usbController = new UsbController(this) {
            @Override
            protected void onUsbModeSetSuccess() {
                Toast.makeText(MainActivity.this,
                        "USB mode set successfully", Toast.LENGTH_SHORT).show();
            }

            @Override
            protected void onUsbModeSetFailed(String errorMessage) {
                Toast.makeText(MainActivity.this,
                        "Failed: " + errorMessage, Toast.LENGTH_LONG).show();
            }
        };

        // Example: Set USB mode to "No data transfer"
        findViewById(R.id.btnNoDataTransfer).setOnClickListener(v -> {
            usbController.setUsbMode("none");
        });

        // Example: Set USB mode to File Transfer (MTP)
        findViewById(R.id.btnFileTransfer).setOnClickListener(v -> {
            usbController.setUsbMode("mtp");
        });

        // Example: Set USB mode to MIDI
        findViewById(R.id.btnMidi).setOnClickListener(v -> {
            usbController.setUsbMode("midi");
        });

        // Example: Set USB mode to PTP
        findViewById(R.id.btnPtp).setOnClickListener(v -> {
            usbController.setUsbMode("ptp");
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        usbController.cleanup();
    }
}
```

##### Testing with ADB

You can test the USB mode control feature from the terminal using ADB (Android Debug Bridge) commands.

###### Set USB Mode (No data transfer)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "none"
```

###### Set USB Mode (File Transfer - MTP)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "mtp"
```

###### Set USB Mode (MIDI)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "midi"
```

###### Set USB Mode (PTP)

```bash
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "ptp"
```

###### Test Result Callback

```bash
# First, monitor the result in logcat
adb logcat | grep "USB_RESULT"

# In another terminal, send the broadcast with the result action
adb shell am broadcast -a com.android.server.startupservice.system --es setting "usb_setting" --es usb_mode "none" --es usb_result_action "com.test.USB_RESULT"
```

---

#### 2.4.3 Volume SDK

##### Overview

The Volume and Sound Settings SDK for Android-App-StartUp provides two APIs that allow external apps
to control the volume of various audio streams on the device via broadcast intents.

- **CONFIG API:** Used to save settings as JSON, which is necessary when settings need to be
  preserved after a reboot.
- **SYSTEM API:** Used for immediate, one-time volume changes without saving the settings.

---

##### Broadcast Actions

###### 1. CONFIG API

- **Action:** `com.android.server.startupservice.config`
- **Feature:** The volume changes immediately upon receiving the broadcast.

###### 2. SYSTEM API

- **Action:** `com.android.server.startupservice.system`
- **Feature:** The volume changes immediately upon receiving the broadcast.

The two APIs are identical in operation, differing only in the action string.

---

##### CONFIG API

Uses the `com.android.server.startupservice.config` action, and parameter names start with the
`volume_` prefix.

###### 1. Media Volume

| Parameter      | Type | Range | Description                                            |
|----------------|------|-------|--------------------------------------------------------|
| `volume_media` | int  | 0-15  | Playback volume for media (music, videos, games, etc.) |

> **Compatibility**
> - Supported on all devices.

**ADB Test Example:**

```bash
# Set media volume to 10
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_media 10
```

###### 2. Ringer Volume

| Parameter         | Type | Range       | Description                                       |
|-------------------|------|-------------|---------------------------------------------------|
| `volume_ringtone` | int  | 0-7 or 0-15 | Incoming call volume. The range varies by device. |

> **Compatibility**
> - **Max value 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
> - **Max value 7:** All other models
>
> **Functional Constraint (Android 14+):**
> - If `volume_ringtone` is set to `0`, `volume_notification` is automatically set to `0`.
>
> **Functional Constraint (Android 13 and below):**
> - Independent control of `volume_ringtone` and `volume_notification` is not possible.

**ADB Test Example:**

```bash
# Set ringer volume to 5
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_ringtone 5
```

###### 3. Notification Volume

| Parameter             | Type | Range       | Description                                      |
|-----------------------|------|-------------|--------------------------------------------------|
| `volume_notification` | int  | 0-7 or 0-15 | Notification volume. The range varies by device. |

> **Compatibility**
> - **OS Dependency:** This parameter operates independently only on **Android 14 (API 34) and
    higher**.
> - **Backward Compatibility:** On Android 13 and below, controlling the notification volume via the
    `volume_notification` broadcast does not work. In this case, adjusting the ringer volume using
    the `volume_ringtone` broadcast will also adjust the notification volume.
> - **Max Value (Android 14+):**
>   - **Max value 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
>   - **Max value 7:** All other models
>   **Functional Constraint (Android 14+):**
> - If `volume_ringtone` is set to `0`, `volume_notification` cannot be set to a value greater than `0`.

**ADB Test Example:**

```bash
# Set notification volume to 5 (Android 14+)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_notification 5
```

###### 4. Alarm Volume

| Parameter      | Type | Range       | Description                               |
|----------------|------|-------------|-------------------------------------------|
| `volume_alarm` | int  | 0-7 or 0-15 | Alarm volume. The range varies by device. |

> **Compatibility**
> - **Max value 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `PC10`
> - **Max value 7:** All other models

**ADB Test Example:**

```bash
# Set alarm volume to 7
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_alarm 7
```

###### 5. Vibrate Mode

| Parameter         | Type    | Description                                                |
|-------------------|---------|------------------------------------------------------------|
| `volume_vibrator` | boolean | `true`: Enable vibrate mode, `false`: Disable vibrate mode |

> **Compatibility**
> - Supported on all devices.
>
> **Functional Constraint:**
> - When set to vibrate mode, `volume_ringtone` and `volume_notification` are automatically adjusted
    to 0.

**ADB Test Example:**

```bash
# Enable vibrate mode
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ez volume_vibrator true
```

###### CONFIG API Full Example

**Kotlin Example:**

```kotlin
// Configure multiple volume settings at once
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

**Java Example:**

```java
// Configure multiple volume settings at once
Intent intent = new Intent("com.android.server.startupservice.config");
intent.putExtra("setting","volume");
intent.putExtra("volume_media",10);
intent.putExtra("volume_ringtone",5);
intent.putExtra("volume_alarm",7);
intent.putExtra("volume_vibrator",false);

if(android.os.Build.VERSION.SDK_INT >=android.os.Build.VERSION_CODES.UPSIDE_DOWN_CAKE){
    intent.putExtra("volume_notification",5);
}
context.sendBroadcast(intent);
```

**ADB Example:**

```bash
# Set and apply multiple volumes at once (based on Android 14+)
adb shell am broadcast -a com.android.server.startupservice.config --es setting "volume" --ei volume_media 10 --ei volume_ringtone 5 --ei volume_notification 5 --ei volume_alarm 7 --ez volume_vibrator false
```

---

##### SYSTEM API

Uses the `com.android.server.startupservice.system` action, and parameter names do not have the
`volume_` prefix.

###### 1. Media Volume

| Parameter | Type | Range | Description                                            |
|-----------|------|-------|--------------------------------------------------------|
| `media`   | int  | 0-15  | Playback volume for media (music, videos, games, etc.) |

> **Compatibility**
> - Supported on all devices.

**ADB Test Example:**

```bash
# Immediately set media volume to 10
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei media 10
```

###### 2. Ringer Volume

| Parameter  | Type | Range       | Description                                       |
|------------|------|-------------|---------------------------------------------------|
| `ringtone` | int  | 0-7 or 0-15 | Incoming call volume. The range varies by device. |

> **Compatibility**
> - **Max value 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
> - **Max value 7:** All other models
>
> **Functional Constraint (Android 14+):**
> - If `ringtone` is set to `0`, `notification` is automatically set to `0`.
>
> **Functional Constraint (Android 13 and below):**
> - Independent control of `ringtone` and `notification` is not possible.

**ADB Test Example:**

```bash
# Immediately set ringer volume to 5
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei ringtone 5
```

###### 3. Notification Volume

| Parameter      | Type | Range       | Description                                      |
|----------------|------|-------------|--------------------------------------------------|
| `notification` | int  | 0-7 or 0-15 | Notification volume. The range varies by device. |

> **Compatibility**
> - **OS Dependency:** This parameter operates independently only on **Android 14 (API 34) and
    higher**.
> - **Backward Compatibility:** On Android 13 and below, controlling the notification volume via the
    `notification` broadcast does not work. In this case, adjusting the ringer volume using the
    `ringtone` broadcast will also adjust the notification volume.
> - **Max Value (Android 14+):**
    >
- **Max value 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `SL25`, `PC10`
>   - **Max value 7:** All other models
>
> **Functional Constraint (Android 14+):**
> - If `ringtone` is set to `0`, `notification` cannot be set to a value greater than `0`.

**ADB Test Example:**

```bash
# Immediately set notification volume to 5 (Android 14+)
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei notification 5
```

###### 4. Alarm Volume

| Parameter | Type | Range       | Description                               |
|-----------|------|-------------|-------------------------------------------|
| `alarm`   | int  | 0-7 or 0-15 | Alarm volume. The range varies by device. |

> **Compatibility**
> - **Max value 15:** `SL10`, `SL10K`, `SL20`, `SL20K`, `SL20P`, `PC10`
> - **Max value 7:** All other models

**ADB Test Example:**

```bash
# Immediately set alarm volume to 7
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei alarm 7
```

###### 5. Vibrate Mode

| Parameter  | Type    | Description                                                |
|------------|---------|------------------------------------------------------------|
| `vibrator` | boolean | `true`: Enable vibrate mode, `false`: Disable vibrate mode |

> **Compatibility**
> - Supported on all devices.
>
> **Functional Constraint:**
> - When set to vibrate mode, `ringtone` and `notification` are automatically adjusted to 0.

**ADB Test Example:**

```bash
# Enable vibrate mode
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ez vibrator true
```

###### SYSTEM API Full Example

**Kotlin Example:**

```kotlin
// Immediately set the media volume to 12
val intent = Intent("com.android.server.startupservice.system").apply {
    putExtra("setting", "volume")
    putExtra("media", 12)
}
context.sendBroadcast(intent)
```

**Java Example:**

```java
// Immediately set the ringer volume to maximum
Intent intent = new Intent("com.android.server.startupservice.system");
intent.putExtra("setting","volume");
intent.putExtra("ringtone",7); // Max value needs to be checked depending on the device model
context.sendBroadcast(intent);
```

**ADB Example:**

```bash
# Immediately set media volume to 12 and alarm volume to 5
adb shell am broadcast -a com.android.server.startupservice.system --es setting "volume" --ei media 12 --ei alarm 5
```

---

