package com.squashtrainingapp.ai;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import com.squashtrainingapp.database.DatabaseHelper;
import com.squashtrainingapp.models.User;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import android.os.Handler;

public class ImprovedAIResponseEngine extends AIResponseEngine {
    private static final String TAG = "ImprovedAIResponseEngine";
    
    private Context context;
    private boolean isKorean = false;
    private ExecutorService executorService;
    private Handler mainHandler;
    private OpenAIClient openAIClient;
    private AIResponseListener listener;
    
    // Enhanced Korean responses
    private static final String[] KOREAN_GREETING_RESPONSES = {
        "안녕하세요! 오늘 스쿼시 트레이닝 준비되셨나요?",
        "반갑습니다! 스쿼시 실력 향상을 위해 무엇을 도와드릴까요?",
        "환영합니다! 오늘의 트레이닝 목표는 무엇인가요?",
        "안녕하세요! 함께 스쿼시 실력을 키워봐요!",
        "좋은 하루입니다! 어떤 부분을 연습하고 싶으신가요?"
    };
    
    private static final String[] KOREAN_WORKOUT_SUGGESTIONS = {
        "오늘은 풋워크에 집중해보세요. 사다리 드릴과 고스팅 연습을 추천합니다.",
        "서브 연습을 해보시는 건 어떨까요? 각 코너에 20개씩, 강약을 조절하며 연습해보세요.",
        "드롭샷과 보스트 연습이 중요합니다. T존 컨트롤에 필수적이에요.",
        "스트레이트 드라이브를 혼자 연습해보세요. 양쪽 각각 50개를 목표로!",
        "버터플라이 드릴로 움직임과 정확도를 향상시켜보세요.",
        "코트 스프린트로 순발력을 기르세요. 베이스라인에서 전방 벽까지 20회!",
        "벽 연습으로 컨트롤을 향상시키세요. 백핸드와 포핸드를 번갈아가며.",
        "레일 샷 연습으로 정확도를 높이세요. 벽에 가깝게 일직선으로!"
    };
    
    private static final String[] KOREAN_TECHNIQUE_TIPS = {
        "라켓을 항상 준비 자세로 들고 있으세요. 반응 시간이 크게 향상됩니다.",
        "공을 치는 것이 아니라 '통과'시킨다는 느낌으로 스윙하세요.",
        "공이 라켓에 닿는 순간까지 시선을 유지하세요. 정확도가 놀랍게 향상됩니다.",
        "백핸드 시 반대 팔로 균형을 잡으세요.",
        "무릎을 더 굽히세요. 낮은 자세가 더 넓은 커버리지를 제공합니다.",
        "T존으로 복귀하는 습관을 들이세요. 코트의 중심이 가장 유리한 위치입니다.",
        "상대의 움직임을 예측하고 미리 포지션을 잡으세요.",
        "체중을 앞발에 실어 공격적인 샷을 구사하세요."
    };
    
    private static final String[] KOREAN_MOTIVATION_QUOTES = {
        "모든 챔피언도 한때는 포기하지 않은 초보자였습니다!",
        "하지 않은 운동만이 나쁜 운동입니다.",
        "꾸준함이 완벽함을 이깁니다. 계속 노력하세요!",
        "오늘의 고통이 내일의 실력이 됩니다.",
        "작은 발전도 발전입니다. 어제보다 나은 오늘을 만드세요!",
        "승리는 준비된 자에게 찾아옵니다.",
        "한계는 마음속에만 존재합니다. 극복하세요!",
        "실패는 성공으로 가는 과정일 뿐입니다."
    };
    
    // Enhanced English responses with more variety
    private static final String[] ENGLISH_GREETING_RESPONSES = {
        "Hello! Ready for some great squash training today?",
        "Hi there! Let's work on improving your squash game!",
        "Welcome back! How can I help with your training?",
        "Good to see you! What aspect of your game shall we focus on?",
        "Hey! Ready to take your squash to the next level?",
        "Greetings! Let's make today's session count!",
        "Hello champion! What's on the training agenda today?"
    };
    
    private static final String[] ENGLISH_WORKOUT_SUGGESTIONS = {
        "Try focusing on your footwork today with ladder drills and ghosting exercises.",
        "Work on your serves - aim for 20 serves to each corner, alternating between hard and soft serves.",
        "Practice your drops and boasts - these are crucial for controlling the T.",
        "Do some solo hitting focusing on straight drives. Aim for 50 on each side.",
        "Try the butterfly drill to improve your movement and shot accuracy.",
        "Court sprints will build explosive power - baseline to front wall, 20 reps!",
        "Wall practice for control - alternate between backhand and forehand.",
        "Rail shots for accuracy - keep it tight to the wall!",
        "Practice your lobs today - height and depth are key.",
        "Work on your volley game - quick reactions at the T zone."
    };
    
    // Strategy and mental game responses
    private static final String[] KOREAN_STRATEGY_TIPS = {
        "상대의 약점을 파악하고 그 부분을 공략하세요.",
        "랠리를 길게 가져가며 상대의 체력을 소모시키세요.",
        "코트의 네 모서리를 활용해 상대를 움직이게 만드세요.",
        "서브 후 빠르게 T존을 차지하세요.",
        "상대가 뒤에 있을 때 드롭샷을 활용하세요."
    };
    
    private static final String[] ENGLISH_STRATEGY_TIPS = {
        "Identify your opponent's weaknesses and exploit them consistently.",
        "Extend rallies to tire out your opponent.",
        "Use all four corners to move your opponent around.",
        "Control the T after your serve.",
        "Use drop shots when your opponent is at the back."
    };
    
    public ImprovedAIResponseEngine(Context context) {
        super(context);
        this.context = context;
        this.executorService = Executors.newSingleThreadExecutor();
        this.mainHandler = new Handler(Looper.getMainLooper());
        this.openAIClient = new OpenAIClient(context);
        checkLanguagePreference();
    }
    
    @Override
    public void setAIResponseListener(AIResponseListener listener) {
        super.setAIResponseListener(listener);
        this.listener = listener;
    }
    
    private void checkLanguagePreference() {
        SharedPreferences prefs = context.getSharedPreferences("app_settings", Context.MODE_PRIVATE);
        String language = prefs.getString("language", "auto");
        
        if (language.equals("ko")) {
            isKorean = true;
        } else if (language.equals("auto")) {
            // Check system locale
            String locale = context.getResources().getConfiguration().locale.getLanguage();
            isKorean = locale.equals("ko");
        }
    }
    
    @Override
    public void getResponse(String userInput) {
        // Try OpenAI first if available
        if (openAIClient.hasApiKey()) {
            openAIClient.sendMessage(userInput, new OpenAIClient.OpenAICallback() {
                @Override
                public void onSuccess(String response) {
                    mainHandler.post(() -> {
                        if (listener != null) {
                            listener.onResponse(response);
                        }
                    });
                }
                
                @Override
                public void onError(String error) {
                    // Fallback to local response on error
                    Log.w(TAG, "OpenAI error, falling back to local: " + error);
                    executorService.execute(() -> {
                        String response = generateImprovedLocalResponse(userInput);
                        mainHandler.post(() -> {
                            if (listener != null) {
                                listener.onResponse(response);
                            }
                        });
                    });
                }
            });
        } else {
            // Use local response generation
            executorService.execute(() -> {
                try {
                    // Simulate processing time
                    Thread.sleep(1000);
                    
                    String response = generateImprovedLocalResponse(userInput);
                    
                    mainHandler.post(() -> {
                        if (listener != null) {
                            listener.onResponse(response);
                        }
                    });
                } catch (Exception e) {
                    Log.e(TAG, "Error generating response", e);
                    mainHandler.post(() -> {
                        if (listener != null) {
                            listener.onAIError(e.getMessage());
                        }
                    });
                }
            });
        }
    }
    
    private String generateImprovedLocalResponse(String userInput) {
        String input = userInput.toLowerCase();
        Random random = new Random();
        
        // Detect language from input
        boolean inputIsKorean = containsKorean(userInput);
        
        // Greetings
        if (input.matches(".*(hello|hi|hey|안녕|반가워|하이).*")) {
            if (inputIsKorean || isKorean) {
                return KOREAN_GREETING_RESPONSES[random.nextInt(KOREAN_GREETING_RESPONSES.length)];
            } else {
                return ENGLISH_GREETING_RESPONSES[random.nextInt(ENGLISH_GREETING_RESPONSES.length)];
            }
        }
        
        // Workout requests
        if (input.matches(".*(workout|exercise|training|practice|운동|트레이닝|연습).*")) {
            if (inputIsKorean || isKorean) {
                return KOREAN_WORKOUT_SUGGESTIONS[random.nextInt(KOREAN_WORKOUT_SUGGESTIONS.length)];
            } else {
                return ENGLISH_WORKOUT_SUGGESTIONS[random.nextInt(ENGLISH_WORKOUT_SUGGESTIONS.length)];
            }
        }
        
        // Technique questions
        if (input.matches(".*(technique|how to|improve|better|form|기술|어떻게|향상|개선|자세).*")) {
            if (inputIsKorean || isKorean) {
                return KOREAN_TECHNIQUE_TIPS[random.nextInt(KOREAN_TECHNIQUE_TIPS.length)];
            } else {
                return ENGLISH_TECHNIQUE_TIPS[random.nextInt(ENGLISH_TECHNIQUE_TIPS.length)];
            }
        }
        
        // Strategy questions
        if (input.matches(".*(strategy|tactic|game plan|전략|전술|작전).*")) {
            if (inputIsKorean || isKorean) {
                return KOREAN_STRATEGY_TIPS[random.nextInt(KOREAN_STRATEGY_TIPS.length)];
            } else {
                return ENGLISH_STRATEGY_TIPS[random.nextInt(ENGLISH_STRATEGY_TIPS.length)];
            }
        }
        
        // Motivation
        if (input.matches(".*(motivat|inspir|tired|difficult|hard|struggle|동기|힘들|어려워|포기).*")) {
            if (inputIsKorean || isKorean) {
                return KOREAN_MOTIVATION_QUOTES[random.nextInt(KOREAN_MOTIVATION_QUOTES.length)];
            } else {
                return ENGLISH_MOTIVATION_QUOTES[random.nextInt(ENGLISH_MOTIVATION_QUOTES.length)];
            }
        }
        
        // Specific technique questions
        if (input.matches(".*(backhand|백핸드).*")) {
            if (inputIsKorean || isKorean) {
                return "백핸드 개선 팁: 1) 어깨를 충분히 돌리세요 2) 팔꿈치를 몸에서 떨어뜨리세요 3) 체중을 앞발로 이동하며 스윙하세요 4) 팔로우스루를 완전히 하세요";
            } else {
                return "Backhand tips: 1) Turn your shoulders fully 2) Keep elbow away from body 3) Transfer weight to front foot 4) Complete your follow-through";
            }
        }
        
        if (input.matches(".*(serve|서브|서브).*")) {
            if (inputIsKorean || isKorean) {
                return "서브 개선: 1) 일정한 토스 높이 유지 2) 타격 지점은 최고점에서 3) 다양한 속도와 각도 연습 4) 서브 후 T존으로 빠른 복귀";
            } else {
                return "Serve improvement: 1) Consistent toss height 2) Hit at the highest point 3) Vary pace and angles 4) Quick recovery to T after serve";
            }
        }
        
        // Equipment questions
        if (input.matches(".*(racket|string|grip|라켓|스트링|그립).*")) {
            if (inputIsKorean || isKorean) {
                return "장비 선택은 개인 스타일에 따라 다릅니다. 초보자는 밸런스가 좋은 중량 라켓(140-160g)을 추천합니다. 스트링 텐션은 25-28lbs가 적당합니다.";
            } else {
                return "Equipment choice depends on your playing style. For beginners, I recommend a balanced racket (140-160g) with string tension around 25-28lbs.";
            }
        }
        
        // Default response
        if (inputIsKorean || isKorean) {
            return "좋은 질문입니다! 스쿼시는 체력, 기술, 전략이 모두 중요한 스포츠입니다. 구체적으로 어떤 부분에 대해 알고 싶으신가요?";
        } else {
            return "Great question! Squash requires fitness, technique, and strategy. What specific aspect would you like to focus on?";
        }
    }
    
    private boolean containsKorean(String text) {
        for (char c : text.toCharArray()) {
            if (Character.UnicodeBlock.of(c) == Character.UnicodeBlock.HANGUL_SYLLABLES ||
                Character.UnicodeBlock.of(c) == Character.UnicodeBlock.HANGUL_JAMO ||
                Character.UnicodeBlock.of(c) == Character.UnicodeBlock.HANGUL_COMPATIBILITY_JAMO) {
                return true;
            }
        }
        return false;
    }
    
    private static final String[] ENGLISH_TECHNIQUE_TIPS = {
        "Keep your racket up and ready between shots - this will improve your reaction time.",
        "Focus on hitting through the ball rather than at it for more power and control.",
        "Watch the ball all the way to your racket - this simple tip improves accuracy significantly.",
        "Use your non-racket arm for balance, especially on the backhand.",
        "Bend your knees more - lower body position gives you better court coverage.",
        "Always return to the T position - it's the most advantageous spot on court.",
        "Anticipate your opponent's shot and position yourself early.",
        "Transfer your weight forward for more aggressive shots.",
        "Keep your wrist firm at impact for better control.",
        "Practice your split-step timing for quicker reactions."
    };
    
    private static final String[] ENGLISH_MOTIVATION_QUOTES = {
        "Every champion was once a beginner who refused to give up!",
        "The only bad workout is the one you didn't do.",
        "Consistency beats perfection - keep showing up!",
        "Today's pain is tomorrow's strength.",
        "Small progress is still progress. Be better than yesterday!",
        "Victory belongs to the prepared.",
        "Limits exist only in the mind. Break through!",
        "Failure is just a stepping stone to success.",
        "Your only competition is who you were yesterday.",
        "Champions are made when no one is watching."
    };
}