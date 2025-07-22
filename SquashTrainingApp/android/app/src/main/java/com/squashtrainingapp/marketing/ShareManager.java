package com.squashtrainingapp.marketing;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Environment;
import android.util.Log;
import android.view.View;

import androidx.core.content.FileProvider;

import com.squashtrainingapp.R;
import com.squashtrainingapp.analytics.AnalyticsService;
import com.squashtrainingapp.auth.FirebaseAuthManager;
import com.squashtrainingapp.models.User;
import com.squashtrainingapp.models.WorkoutSession;

import java.io.File;
import java.io.FileOutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class ShareManager {
    private static final String TAG = "ShareManager";
    private static final String SHARE_AUTHORITY = "com.squashtrainingapp.fileprovider";
    
    private Context context;
    private FirebaseAuthManager authManager;
    private ReferralService referralService;
    
    // Share types
    public enum ShareType {
        ACHIEVEMENT,        // Share achievement
        WORKOUT_SUMMARY,    // Share workout results
        WEEKLY_STATS,       // Share weekly statistics
        REFERRAL_LINK,      // Share app with referral code
        CHALLENGE_INVITE,   // Invite to challenge
        LEADERBOARD         // Share leaderboard position
    }
    
    // Social platforms
    public enum Platform {
        GENERAL,           // System share sheet
        FACEBOOK,
        INSTAGRAM,
        TWITTER,
        WHATSAPP,
        KAKAOTALK
    }
    
    public ShareManager(Context context) {
        this.context = context;
        this.authManager = FirebaseAuthManager.getInstance(context);
        this.referralService = new ReferralService(context);
    }
    
    // Share achievement
    public void shareAchievement(String achievementTitle, String description, int badgeResId) {
        String shareText = String.format(
            "🏆 %s 달성!\n\n%s\n\n스쿼시 트레이닝 앱에서 함께 운동해요!\n%s",
            achievementTitle,
            description,
            getAppShareLink()
        );
        
        // Create achievement image
        Bitmap achievementImage = createAchievementImage(achievementTitle, badgeResId);
        
        if (achievementImage != null) {
            shareImageWithText(achievementImage, shareText, "achievement.png");
        } else {
            shareText(shareText, "업적 공유");
        }
    }
    
    // Share workout summary
    public void shareWorkoutSummary(WorkoutSession session, AnalyticsService.WorkoutStats stats) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy년 MM월 dd일", Locale.KOREAN);
        String dateStr = dateFormat.format(new Date());
        
        String shareText = String.format(
            "💪 오늘의 스쿼시 운동 완료!\n\n" +
            "📅 %s\n" +
            "⏱️ 운동 시간: %d분\n" +
            "🔥 칼로리 소모: %d kcal\n" +
            "🎯 이번 주 %d회째 운동\n\n" +
            "스쿼시 트레이닝 앱으로 건강한 습관을 만들어보세요!\n%s",
            dateStr,
            session.getDurationMinutes(),
            calculateCalories(session),
            stats != null ? stats.totalSessions : 1,
            getAppShareLink()
        );
        
        // Create workout summary image
        Bitmap summaryImage = createWorkoutSummaryImage(session, stats);
        
        if (summaryImage != null) {
            shareImageWithText(summaryImage, shareText, "workout_summary.png");
        } else {
            shareText(shareText, "운동 기록 공유");
        }
    }
    
    // Share weekly statistics
    public void shareWeeklyStats(AnalyticsService.AnalyticsData analyticsData) {
        if (analyticsData == null || analyticsData.workoutStats == null) return;
        
        String shareText = String.format(
            "📊 이번 주 스쿼시 운동 통계\n\n" +
            "🏃 총 운동 횟수: %d회\n" +
            "⏱️ 총 운동 시간: %d분\n" +
            "🔥 총 칼로리 소모: %d kcal\n" +
            "📈 연속 운동: %d일\n\n" +
            "꾸준한 운동으로 건강을 지켜요! 💪\n%s",
            analyticsData.workoutStats.totalSessions,
            analyticsData.fitnessStats != null ? analyticsData.fitnessStats.totalMinutesExercised : 0,
            analyticsData.fitnessStats != null ? analyticsData.fitnessStats.totalCaloriesBurned : 0,
            analyticsData.workoutStats.currentStreak,
            getAppShareLink()
        );
        
        shareText(shareText, "주간 통계 공유");
    }
    
    // Share referral link
    public void shareReferralLink() {
        referralService.generateReferralCode(new ReferralService.ReferralCallback() {
            @Override
            public void onSuccess(String referralCode) {
                String shareText = String.format(
                    "🎾 스쿼시 트레이닝 앱 추천!\n\n" +
                    "AI 코치와 함께하는 맞춤형 스쿼시 트레이닝 🤖\n\n" +
                    "지금 가입하면:\n" +
                    "✅ 첫 달 50%% 할인\n" +
                    "✅ 7일 무료 체험\n" +
                    "✅ 프리미엄 콘텐츠 접근\n\n" +
                    "추천 코드: %s\n" +
                    "링크: %s\n\n" +
                    "#스쿼시 #운동 #AI코치",
                    referralCode,
                    getReferralLink(referralCode)
                );
                
                shareText(shareText, "친구 초대하기");
            }
            
            @Override
            public void onError(String error) {
                Log.e(TAG, "Failed to generate referral code: " + error);
                shareText(getAppShareLink(), "앱 공유하기");
            }
        });
    }
    
    // Share to specific platform
    public void shareToPlatform(String text, Platform platform) {
        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        shareIntent.setType("text/plain");
        shareIntent.putExtra(Intent.EXTRA_TEXT, text);
        
        String packageName = getPackageNameForPlatform(platform);
        if (packageName != null && isAppInstalled(packageName)) {
            shareIntent.setPackage(packageName);
        }
        
        try {
            context.startActivity(Intent.createChooser(shareIntent, "공유하기"));
        } catch (Exception e) {
            Log.e(TAG, "Failed to share", e);
        }
    }
    
    // Share challenge invite
    public void shareChallengeInvite(String challengeTitle, String challengeId) {
        String shareText = String.format(
            "🏆 스쿼시 챌린지 초대!\n\n" +
            "「%s」에 도전해보세요!\n\n" +
            "함께 운동하고 경쟁하며 실력을 키워요 💪\n\n" +
            "참여 링크: %s",
            challengeTitle,
            getChallengeLink(challengeId)
        );
        
        shareText(shareText, "챌린지 초대");
    }
    
    // Share leaderboard position
    public void shareLeaderboardPosition(int rank, String category) {
        String medal = "";
        if (rank == 1) medal = "🥇";
        else if (rank == 2) medal = "🥈";
        else if (rank == 3) medal = "🥉";
        else medal = "🏅";
        
        String shareText = String.format(
            "%s %s 부문 %d위 달성!\n\n" +
            "열심히 운동한 결과입니다 💪\n" +
            "당신도 도전해보세요!\n\n%s",
            medal,
            category,
            rank,
            getAppShareLink()
        );
        
        shareText(shareText, "순위 공유");
    }
    
    // Helper methods
    private void shareText(String text, String title) {
        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        shareIntent.setType("text/plain");
        shareIntent.putExtra(Intent.EXTRA_TEXT, text);
        
        context.startActivity(Intent.createChooser(shareIntent, title));
    }
    
    private void shareImageWithText(Bitmap image, String text, String filename) {
        try {
            // Save image to cache
            File cachePath = new File(context.getCacheDir(), "images");
            cachePath.mkdirs();
            File imageFile = new File(cachePath, filename);
            
            FileOutputStream stream = new FileOutputStream(imageFile);
            image.compress(Bitmap.CompressFormat.PNG, 100, stream);
            stream.close();
            
            // Get URI using FileProvider
            Uri contentUri = FileProvider.getUriForFile(context, SHARE_AUTHORITY, imageFile);
            
            // Create share intent
            Intent shareIntent = new Intent(Intent.ACTION_SEND);
            shareIntent.setType("image/*");
            shareIntent.putExtra(Intent.EXTRA_STREAM, contentUri);
            shareIntent.putExtra(Intent.EXTRA_TEXT, text);
            shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            
            context.startActivity(Intent.createChooser(shareIntent, "공유하기"));
        } catch (Exception e) {
            Log.e(TAG, "Failed to share image", e);
            // Fallback to text only
            shareText(text, "공유하기");
        }
    }
    
    private Bitmap createAchievementImage(String title, int badgeResId) {
        try {
            int width = 1080;
            int height = 1080;
            
            Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(bitmap);
            
            // Background
            Paint bgPaint = new Paint();
            bgPaint.setColor(Color.parseColor("#1E88E5"));
            canvas.drawRect(0, 0, width, height, bgPaint);
            
            // Title
            Paint titlePaint = new Paint();
            titlePaint.setColor(Color.WHITE);
            titlePaint.setTextSize(80);
            titlePaint.setTypeface(Typeface.create(Typeface.DEFAULT, Typeface.BOLD));
            titlePaint.setTextAlign(Paint.Align.CENTER);
            canvas.drawText(title, width / 2, height / 2 - 100, titlePaint);
            
            // App name
            Paint appPaint = new Paint();
            appPaint.setColor(Color.WHITE);
            appPaint.setTextSize(40);
            appPaint.setTextAlign(Paint.Align.CENTER);
            canvas.drawText("Squash Training App", width / 2, height - 100, appPaint);
            
            return bitmap;
        } catch (Exception e) {
            Log.e(TAG, "Failed to create achievement image", e);
            return null;
        }
    }
    
    private Bitmap createWorkoutSummaryImage(WorkoutSession session, AnalyticsService.WorkoutStats stats) {
        // Similar implementation to createAchievementImage
        // but with workout statistics
        return null; // Simplified for now
    }
    
    private String getPackageNameForPlatform(Platform platform) {
        switch (platform) {
            case FACEBOOK:
                return "com.facebook.katana";
            case INSTAGRAM:
                return "com.instagram.android";
            case TWITTER:
                return "com.twitter.android";
            case WHATSAPP:
                return "com.whatsapp";
            case KAKAOTALK:
                return "com.kakao.talk";
            default:
                return null;
        }
    }
    
    private boolean isAppInstalled(String packageName) {
        try {
            context.getPackageManager().getPackageInfo(packageName, 0);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    private int calculateCalories(WorkoutSession session) {
        // Simple calculation: 10 calories per minute
        return session.getDurationMinutes() * 10;
    }
    
    private String getAppShareLink() {
        return "https://play.google.com/store/apps/details?id=com.squashtrainingapp";
    }
    
    private String getReferralLink(String referralCode) {
        return String.format("https://squashtraining.app/invite?code=%s", referralCode);
    }
    
    private String getChallengeLink(String challengeId) {
        return String.format("https://squashtraining.app/challenge?id=%s", challengeId);
    }
}