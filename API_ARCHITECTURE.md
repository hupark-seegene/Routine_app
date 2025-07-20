# API Architecture Design - Squash Training App

## 🎯 Overview
이 문서는 Squash Training App의 API 통합 아키텍처를 정의합니다. 안전하고 확장 가능한 API 연결을 위한 설계입니다.

## 🔑 API 통합 목록

### 1. OpenAI API (AI Coach)
- **용도**: AI 코칭, 개인화된 조언, 자연어 처리
- **엔드포인트**: https://api.openai.com/v1/
- **인증**: Bearer Token (API Key)
- **모델**: GPT-3.5-turbo (현재), GPT-4 (계획)

### 2. Google Speech-to-Text API
- **용도**: 음성 명령 인식
- **엔드포인트**: https://speech.googleapis.com/v1/
- **인증**: API Key 또는 Service Account
- **언어**: ko-KR, en-US

### 3. YouTube Data API
- **용도**: 운동 영상 추천
- **엔드포인트**: https://www.googleapis.com/youtube/v3/
- **인증**: API Key
- **할당량**: 10,000 units/day

### 4. Firebase (계획)
- **용도**: 사용자 인증, 데이터 동기화, 푸시 알림
- **서비스**: 
  - Authentication
  - Firestore
  - Cloud Functions
  - Cloud Messaging

### 5. Custom Backend API (향후)
- **용도**: 사용자 데이터 동기화, 리더보드, 소셜 기능
- **엔드포인트**: https://api.squashtraining.app/v1/
- **인증**: JWT Token

## 🏗️ API 아키텍처 설계

### 레이어 구조
```
┌─────────────────────────────────┐
│      UI Layer (Activities)       │
├─────────────────────────────────┤
│    Repository Layer              │
├─────────────────────────────────┤
│    API Service Layer             │
├─────────────────────────────────┤
│    Network Layer (Retrofit)     │
└─────────────────────────────────┘
```

### 패키지 구조
```
com.squashtrainingapp/
├── api/
│   ├── config/
│   │   ├── ApiConfig.java
│   │   ├── ApiKeyManager.java
│   │   └── NetworkConfig.java
│   ├── services/
│   │   ├── OpenAIService.java
│   │   ├── SpeechService.java
│   │   ├── YouTubeService.java
│   │   └── FirebaseService.java
│   ├── models/
│   │   ├── request/
│   │   │   ├── ChatRequest.java
│   │   │   └── SpeechRequest.java
│   │   └── response/
│   │       ├── ChatResponse.java
│   │       └── SpeechResponse.java
│   ├── interceptors/
│   │   ├── AuthInterceptor.java
│   │   ├── LoggingInterceptor.java
│   │   └── ErrorInterceptor.java
│   └── repository/
│       ├── AIRepository.java
│       └── MediaRepository.java
```

## 💻 구현 코드

### 1. API Configuration
```java
// ApiConfig.java
package com.squashtrainingapp.api.config;

public class ApiConfig {
    // Base URLs
    public static final String OPENAI_BASE_URL = "https://api.openai.com/v1/";
    public static final String GOOGLE_SPEECH_BASE_URL = "https://speech.googleapis.com/v1/";
    public static final String YOUTUBE_BASE_URL = "https://www.googleapis.com/youtube/v3/";
    
    // Timeouts
    public static final int CONNECT_TIMEOUT = 30;
    public static final int READ_TIMEOUT = 30;
    public static final int WRITE_TIMEOUT = 30;
    
    // API Versions
    public static final String API_VERSION = "v1";
    
    // Models
    public static final String GPT_MODEL = "gpt-3.5-turbo";
    public static final int MAX_TOKENS = 1000;
}
```

### 2. API Key Manager
```java
// ApiKeyManager.java
package com.squashtrainingapp.api.config;

import android.content.Context;
import android.content.SharedPreferences;
import androidx.security.crypto.EncryptedSharedPreferences;
import androidx.security.crypto.MasterKey;

public class ApiKeyManager {
    private static final String PREFS_NAME = "api_keys";
    private static final String KEY_OPENAI = "openai_api_key";
    private static final String KEY_GOOGLE = "google_api_key";
    private static final String KEY_YOUTUBE = "youtube_api_key";
    
    private SharedPreferences encryptedPrefs;
    
    public ApiKeyManager(Context context) {
        try {
            MasterKey masterKey = new MasterKey.Builder(context)
                .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                .build();
                
            encryptedPrefs = EncryptedSharedPreferences.create(
                context,
                PREFS_NAME,
                masterKey,
                EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public void saveOpenAIKey(String apiKey) {
        encryptedPrefs.edit().putString(KEY_OPENAI, apiKey).apply();
    }
    
    public String getOpenAIKey() {
        return encryptedPrefs.getString(KEY_OPENAI, "");
    }
    
    public boolean hasValidKeys() {
        return !getOpenAIKey().isEmpty();
    }
}
```

### 3. Network Configuration
```java
// NetworkConfig.java
package com.squashtrainingapp.api.config;

import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.util.concurrent.TimeUnit;

public class NetworkConfig {
    private static Retrofit retrofitOpenAI;
    private static Retrofit retrofitGoogle;
    private static Retrofit retrofitYouTube;
    
    public static Retrofit getOpenAIClient(String apiKey) {
        if (retrofitOpenAI == null) {
            OkHttpClient client = new OkHttpClient.Builder()
                .connectTimeout(ApiConfig.CONNECT_TIMEOUT, TimeUnit.SECONDS)
                .readTimeout(ApiConfig.READ_TIMEOUT, TimeUnit.SECONDS)
                .writeTimeout(ApiConfig.WRITE_TIMEOUT, TimeUnit.SECONDS)
                .addInterceptor(new AuthInterceptor(apiKey))
                .addInterceptor(new LoggingInterceptor())
                .addInterceptor(new ErrorInterceptor())
                .build();
                
            Gson gson = new GsonBuilder()
                .setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
                .create();
                
            retrofitOpenAI = new Retrofit.Builder()
                .baseUrl(ApiConfig.OPENAI_BASE_URL)
                .client(client)
                .addConverterFactory(GsonConverterFactory.create(gson))
                .build();
        }
        return retrofitOpenAI;
    }
}
```

### 4. OpenAI Service Implementation
```java
// OpenAIService.java
package com.squashtrainingapp.api.services;

import retrofit2.Call;
import retrofit2.http.*;
import com.squashtrainingapp.api.models.request.ChatRequest;
import com.squashtrainingapp.api.models.response.ChatResponse;

public interface OpenAIService {
    @POST("chat/completions")
    Call<ChatResponse> createChatCompletion(@Body ChatRequest request);
    
    @POST("audio/transcriptions")
    @Multipart
    Call<TranscriptionResponse> createTranscription(
        @Part MultipartBody.Part file,
        @Part("model") RequestBody model,
        @Part("language") RequestBody language
    );
}
```

### 5. Request/Response Models
```java
// ChatRequest.java
package com.squashtrainingapp.api.models.request;

import java.util.List;

public class ChatRequest {
    private String model;
    private List<Message> messages;
    private int max_tokens;
    private double temperature;
    
    public static class Message {
        private String role;
        private String content;
        
        public Message(String role, String content) {
            this.role = role;
            this.content = content;
        }
    }
    
    public static class Builder {
        private String model = "gpt-3.5-turbo";
        private List<Message> messages;
        private int maxTokens = 1000;
        private double temperature = 0.7;
        
        public Builder messages(List<Message> messages) {
            this.messages = messages;
            return this;
        }
        
        public ChatRequest build() {
            ChatRequest request = new ChatRequest();
            request.model = this.model;
            request.messages = this.messages;
            request.max_tokens = this.maxTokens;
            request.temperature = this.temperature;
            return request;
        }
    }
}
```

### 6. AI Repository
```java
// AIRepository.java
package com.squashtrainingapp.api.repository;

import android.content.Context;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import java.util.ArrayList;
import java.util.List;

public class AIRepository {
    private OpenAIService openAIService;
    private ApiKeyManager apiKeyManager;
    private MutableLiveData<String> chatResponse = new MutableLiveData<>();
    private MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);
    private MutableLiveData<String> error = new MutableLiveData<>();
    
    public AIRepository(Context context) {
        apiKeyManager = new ApiKeyManager(context);
        String apiKey = apiKeyManager.getOpenAIKey();
        if (!apiKey.isEmpty()) {
            openAIService = NetworkConfig.getOpenAIClient(apiKey)
                .create(OpenAIService.class);
        }
    }
    
    public void sendChatMessage(String userMessage) {
        if (openAIService == null) {
            error.setValue("API key not configured");
            return;
        }
        
        isLoading.setValue(true);
        
        List<ChatRequest.Message> messages = new ArrayList<>();
        messages.add(new ChatRequest.Message("system", 
            "You are a professional squash coach. Provide helpful advice for improving squash skills."));
        messages.add(new ChatRequest.Message("user", userMessage));
        
        ChatRequest request = new ChatRequest.Builder()
            .messages(messages)
            .build();
            
        openAIService.createChatCompletion(request).enqueue(new Callback<ChatResponse>() {
            @Override
            public void onResponse(Call<ChatResponse> call, Response<ChatResponse> response) {
                isLoading.setValue(false);
                if (response.isSuccessful() && response.body() != null) {
                    String reply = response.body().getChoices().get(0).getMessage().getContent();
                    chatResponse.setValue(reply);
                } else {
                    error.setValue("Failed to get response");
                }
            }
            
            @Override
            public void onFailure(Call<ChatResponse> call, Throwable t) {
                isLoading.setValue(false);
                error.setValue("Network error: " + t.getMessage());
            }
        });
    }
    
    public LiveData<String> getChatResponse() { return chatResponse; }
    public LiveData<Boolean> getIsLoading() { return isLoading; }
    public LiveData<String> getError() { return error; }
}
```

### 7. Interceptors
```java
// AuthInterceptor.java
package com.squashtrainingapp.api.interceptors;

import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;
import java.io.IOException;

public class AuthInterceptor implements Interceptor {
    private String apiKey;
    
    public AuthInterceptor(String apiKey) {
        this.apiKey = apiKey;
    }
    
    @Override
    public Response intercept(Chain chain) throws IOException {
        Request original = chain.request();
        Request request = original.newBuilder()
            .header("Authorization", "Bearer " + apiKey)
            .header("Content-Type", "application/json")
            .build();
        return chain.proceed(request);
    }
}

// ErrorInterceptor.java
package com.squashtrainingapp.api.interceptors;

import okhttp3.Interceptor;
import okhttp3.Response;
import java.io.IOException;
import android.util.Log;

public class ErrorInterceptor implements Interceptor {
    private static final String TAG = "API_ERROR";
    
    @Override
    public Response intercept(Chain chain) throws IOException {
        Response response = chain.proceed(chain.request());
        
        if (!response.isSuccessful()) {
            Log.e(TAG, "API Error: " + response.code() + " " + response.message());
            
            switch (response.code()) {
                case 401:
                    // Handle unauthorized
                    break;
                case 429:
                    // Handle rate limit
                    break;
                case 500:
                    // Handle server error
                    break;
            }
        }
        
        return response;
    }
}
```

### 8. Network State Manager
```java
// NetworkStateManager.java
package com.squashtrainingapp.api.config;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkRequest;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

public class NetworkStateManager {
    private static NetworkStateManager instance;
    private ConnectivityManager connectivityManager;
    private MutableLiveData<Boolean> isNetworkAvailable = new MutableLiveData<>(false);
    
    private NetworkStateManager(Context context) {
        connectivityManager = (ConnectivityManager) 
            context.getSystemService(Context.CONNECTIVITY_SERVICE);
        registerNetworkCallback();
    }
    
    public static synchronized NetworkStateManager getInstance(Context context) {
        if (instance == null) {
            instance = new NetworkStateManager(context.getApplicationContext());
        }
        return instance;
    }
    
    private void registerNetworkCallback() {
        NetworkRequest networkRequest = new NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build();
            
        connectivityManager.registerNetworkCallback(networkRequest, 
            new ConnectivityManager.NetworkCallback() {
                @Override
                public void onAvailable(Network network) {
                    isNetworkAvailable.postValue(true);
                }
                
                @Override
                public void onLost(Network network) {
                    isNetworkAvailable.postValue(false);
                }
            });
    }
    
    public LiveData<Boolean> getNetworkState() {
        return isNetworkAvailable;
    }
    
    public boolean isConnected() {
        Network network = connectivityManager.getActiveNetwork();
        if (network == null) return false;
        
        NetworkCapabilities capabilities = 
            connectivityManager.getNetworkCapabilities(network);
        return capabilities != null && 
            capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET);
    }
}
```

## 🔒 보안 고려사항

### 1. API Key 보안
- EncryptedSharedPreferences 사용
- ProGuard/R8으로 코드 난독화
- API Key를 하드코딩하지 않음
- 개발자 모드에서만 API Key 입력 가능

### 2. 네트워크 보안
- HTTPS 전용 통신
- Certificate Pinning (향후)
- Request/Response 암호화
- 민감한 데이터 로깅 방지

### 3. 에러 처리
- API 에러 코드별 처리
- Rate Limiting 대응
- Offline 모드 지원
- 재시도 메커니즘

## 📱 사용 예시

### AI Coach Activity에서 사용
```java
public class AIChatbotActivity extends AppCompatActivity {
    private AIRepository aiRepository;
    private EditText messageInput;
    private RecyclerView chatRecyclerView;
    private ChatAdapter chatAdapter;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_ai_chatbot);
        
        aiRepository = new AIRepository(this);
        setupViews();
        observeData();
    }
    
    private void observeData() {
        aiRepository.getChatResponse().observe(this, response -> {
            if (response != null) {
                chatAdapter.addMessage(new ChatMessage("AI", response));
            }
        });
        
        aiRepository.getIsLoading().observe(this, isLoading -> {
            // Show/hide loading indicator
        });
        
        aiRepository.getError().observe(this, error -> {
            if (error != null) {
                Toast.makeText(this, error, Toast.LENGTH_SHORT).show();
            }
        });
    }
    
    private void sendMessage() {
        String message = messageInput.getText().toString();
        if (!message.isEmpty()) {
            chatAdapter.addMessage(new ChatMessage("User", message));
            aiRepository.sendChatMessage(message);
            messageInput.setText("");
        }
    }
}
```

## 🚀 향후 계획

### Phase 1 (즉시)
- OpenAI API 통합 완성
- API Key 관리 UI 구현
- 오프라인 모드 대응

### Phase 2 (2주)
- Google Speech API 통합
- YouTube API 통합
- 캐싱 메커니즘 구현

### Phase 3 (4주)
- Firebase 통합
- 실시간 데이터 동기화
- 푸시 알림 구현

### Phase 4 (6주)
- Custom Backend API 개발
- GraphQL 도입 검토
- WebSocket 실시간 통신

이 설계를 통해 안전하고 확장 가능한 API 연동을 구현할 수 있습니다.