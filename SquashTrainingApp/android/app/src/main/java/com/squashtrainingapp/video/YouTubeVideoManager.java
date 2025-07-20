package com.squashtrainingapp.video;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import com.squashtrainingapp.models.VideoTutorial;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class YouTubeVideoManager {
    private static final String TAG = "YouTubeVideoManager";
    
    private Context context;
    private Map<String, List<VideoTutorial>> videoDatabase;
    
    public YouTubeVideoManager(Context context) {
        this.context = context;
        initializeVideoDatabase();
    }
    
    private void initializeVideoDatabase() {
        videoDatabase = new HashMap<>();
        
        // Beginner videos
        List<VideoTutorial> beginnerVideos = new ArrayList<>();
        beginnerVideos.add(new VideoTutorial(
            "basic_grip",
            "스쿼시 기본 그립",
            "올바른 라켓 그립 방법을 배웁니다",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ", // Example URL
            "5:30",
            VideoTutorial.Level.BEGINNER,
            VideoTutorial.Category.TECHNIQUE
        ));
        beginnerVideos.add(new VideoTutorial(
            "basic_stance",
            "기본 스탠스와 자세",
            "스쿼시의 기본 자세를 마스터합니다",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "7:15",
            VideoTutorial.Level.BEGINNER,
            VideoTutorial.Category.TECHNIQUE
        ));
        beginnerVideos.add(new VideoTutorial(
            "first_serve",
            "첫 서브 배우기",
            "기본 서브 동작을 단계별로 익힙니다",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "8:45",
            VideoTutorial.Level.BEGINNER,
            VideoTutorial.Category.TECHNIQUE
        ));
        videoDatabase.put("beginner", beginnerVideos);
        
        // Intermediate videos
        List<VideoTutorial> intermediateVideos = new ArrayList<>();
        intermediateVideos.add(new VideoTutorial(
            "drop_shot",
            "드롭샷 마스터하기",
            "효과적인 드롭샷 기술을 배웁니다",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "10:20",
            VideoTutorial.Level.INTERMEDIATE,
            VideoTutorial.Category.TECHNIQUE
        ));
        intermediateVideos.add(new VideoTutorial(
            "court_movement",
            "코트 움직임 패턴",
            "효율적인 코트 커버리지 전략",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "12:30",
            VideoTutorial.Level.INTERMEDIATE,
            VideoTutorial.Category.TACTICS
        ));
        intermediateVideos.add(new VideoTutorial(
            "interval_training",
            "인터벌 트레이닝",
            "스쿼시 특화 체력 훈련",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "15:00",
            VideoTutorial.Level.INTERMEDIATE,
            VideoTutorial.Category.FITNESS
        ));
        videoDatabase.put("intermediate", intermediateVideos);
        
        // Advanced videos
        List<VideoTutorial> advancedVideos = new ArrayList<>();
        advancedVideos.add(new VideoTutorial(
            "deception",
            "디셉션 기술",
            "상대를 속이는 고급 기술",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "11:45",
            VideoTutorial.Level.ADVANCED,
            VideoTutorial.Category.TECHNIQUE
        ));
        advancedVideos.add(new VideoTutorial(
            "match_analysis",
            "경기 분석 방법",
            "프로 선수의 경기 분석",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "20:00",
            VideoTutorial.Level.ADVANCED,
            VideoTutorial.Category.TACTICS
        ));
        advancedVideos.add(new VideoTutorial(
            "mental_game",
            "정신력 강화",
            "압박 상황에서의 멘탈 관리",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "13:30",
            VideoTutorial.Level.ADVANCED,
            VideoTutorial.Category.MENTAL
        ));
        videoDatabase.put("advanced", advancedVideos);
        
        // Drills videos
        List<VideoTutorial> drillVideos = new ArrayList<>();
        drillVideos.add(new VideoTutorial(
            "solo_drills",
            "혼자하는 드릴",
            "파트너 없이 연습하는 방법",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "9:00",
            VideoTutorial.Level.ALL,
            VideoTutorial.Category.DRILLS
        ));
        drillVideos.add(new VideoTutorial(
            "wall_practice",
            "벽 연습 루틴",
            "효과적인 벽 연습 방법",
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "7:30",
            VideoTutorial.Level.ALL,
            VideoTutorial.Category.DRILLS
        ));
        videoDatabase.put("drills", drillVideos);
    }
    
    public List<VideoTutorial> getVideosForLevel(VideoTutorial.Level level) {
        switch (level) {
            case BEGINNER:
                return videoDatabase.get("beginner");
            case INTERMEDIATE:
                return videoDatabase.get("intermediate");
            case ADVANCED:
                return videoDatabase.get("advanced");
            default:
                return new ArrayList<>();
        }
    }
    
    public List<VideoTutorial> getVideosForCategory(VideoTutorial.Category category) {
        List<VideoTutorial> result = new ArrayList<>();
        for (List<VideoTutorial> videos : videoDatabase.values()) {
            for (VideoTutorial video : videos) {
                if (video.getCategory() == category) {
                    result.add(video);
                }
            }
        }
        return result;
    }
    
    public List<VideoTutorial> searchVideos(String query) {
        List<VideoTutorial> result = new ArrayList<>();
        String lowerQuery = query.toLowerCase();
        
        for (List<VideoTutorial> videos : videoDatabase.values()) {
            for (VideoTutorial video : videos) {
                if (video.getTitle().toLowerCase().contains(lowerQuery) ||
                    video.getDescription().toLowerCase().contains(lowerQuery)) {
                    result.add(video);
                }
            }
        }
        return result;
    }
    
    public List<VideoTutorial> getRecommendedVideos(int userLevel) {
        List<VideoTutorial> recommendations = new ArrayList<>();
        
        // Add videos based on user level
        if (userLevel <= 3) {
            recommendations.addAll(getVideosForLevel(VideoTutorial.Level.BEGINNER));
            // Add some intermediate videos for progression
            List<VideoTutorial> intermediate = getVideosForLevel(VideoTutorial.Level.INTERMEDIATE);
            if (intermediate.size() > 0) {
                recommendations.add(intermediate.get(0));
            }
        } else if (userLevel <= 7) {
            recommendations.addAll(getVideosForLevel(VideoTutorial.Level.INTERMEDIATE));
            // Add one advanced video for challenge
            List<VideoTutorial> advanced = getVideosForLevel(VideoTutorial.Level.ADVANCED);
            if (advanced.size() > 0) {
                recommendations.add(advanced.get(0));
            }
        } else {
            recommendations.addAll(getVideosForLevel(VideoTutorial.Level.ADVANCED));
        }
        
        // Always include some drills
        recommendations.addAll(videoDatabase.get("drills"));
        
        return recommendations;
    }
    
    public void playVideo(VideoTutorial video) {
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setData(Uri.parse(video.getUrl()));
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
        } catch (Exception e) {
            Log.e(TAG, "Error playing video: " + e.getMessage());
            // Fallback to web browser
            Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(video.getUrl()));
            browserIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(browserIntent);
        }
    }
    
    public String getThumbnailUrl(String videoUrl) {
        // Extract video ID from YouTube URL
        String videoId = extractVideoId(videoUrl);
        if (videoId != null) {
            return "https://img.youtube.com/vi/" + videoId + "/hqdefault.jpg";
        }
        return null;
    }
    
    private String extractVideoId(String videoUrl) {
        String videoId = null;
        if (videoUrl != null && videoUrl.contains("youtube.com/watch?v=")) {
            int start = videoUrl.indexOf("v=") + 2;
            int end = videoUrl.indexOf("&", start);
            if (end == -1) {
                videoId = videoUrl.substring(start);
            } else {
                videoId = videoUrl.substring(start, end);
            }
        } else if (videoUrl != null && videoUrl.contains("youtu.be/")) {
            int start = videoUrl.lastIndexOf("/") + 1;
            int end = videoUrl.indexOf("?", start);
            if (end == -1) {
                videoId = videoUrl.substring(start);
            } else {
                videoId = videoUrl.substring(start, end);
            }
        }
        return videoId;
    }
}