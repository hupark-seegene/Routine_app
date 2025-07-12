import { getAPIConfig, API_ENDPOINTS, API_ERRORS } from './config';
import AsyncStorage from '../../utils/SQLiteAsyncStorage';
import { devLog, devError } from '../../utils/environment';
import { fetchJsonWithRetry, handleApiError } from '../../utils/networkUtils';

interface AIResponse {
  advice: string;
  confidence: number;
  timestamp: number;
}

interface TrainingData {
  skillLevel: string;
  recentScores: number[];
  practiceFrequency: number;
  weakAreas: string[];
  goals: string[];
}

class AIApiService {
  private cacheKey = 'AI_ADVICE_CACHE';
  private developerApiKey: string | null = null;

  // Set developer API key for authenticated users
  setDeveloperApiKey(apiKey: string | null) {
    this.developerApiKey = apiKey;
  }

  // Get AI advice based on training data
  async getCoachingAdvice(trainingData: TrainingData): Promise<AIResponse> {
    try {
      // Check cache first
      const cachedAdvice = await this.getCachedAdvice(trainingData);
      if (cachedAdvice) {
        return cachedAdvice;
      }

      // Prepare the prompt
      const prompt = this.buildCoachingPrompt(trainingData);

      // Get advice from AI
      const config = getAPIConfig(this.developerApiKey);
      let advice: string;
      if (config.AI.DEFAULT_PROVIDER === 'anthropic') {
        advice = await this.getAnthropicAdvice(prompt);
      } else {
        advice = await this.getOpenAIAdvice(prompt);
      }

      const response: AIResponse = {
        advice,
        confidence: 0.85, // Confidence score for the advice
        timestamp: Date.now(),
      };

      // Cache the response
      await this.cacheAdvice(trainingData, response);

      return response;
    } catch (error: any) {
      devError('AI API Error:', error);
      // Re-throw with user-friendly message if not already handled
      if (error.message && !error.message.includes('Please')) {
        throw new Error(handleApiError(error));
      }
      throw error;
    }
  }

  // Build coaching prompt based on training data
  private buildCoachingPrompt(data: TrainingData): string {
    return `As a squash coach, provide brief, actionable advice for a player with the following profile:
    - Skill Level: ${data.skillLevel}
    - Recent Performance Scores: ${data.recentScores.join(', ')}
    - Practice Frequency: ${data.practiceFrequency} times per week
    - Weak Areas: ${data.weakAreas.join(', ')}
    - Goals: ${data.goals.join(', ')}
    
    Provide 2-3 specific, practical tips to improve their game. Keep the response under 150 words.`;
  }

  // Get advice from Anthropic Claude
  private async getAnthropicAdvice(prompt: string): Promise<string> {
    const config = getAPIConfig(this.developerApiKey);
    const apiKey = config.AI.ANTHROPIC_API_KEY;
    if (!apiKey) {
      throw new Error(API_ERRORS.NO_API_KEY);
    }

    try {
      const data = await fetchJsonWithRetry<any>(
        `${config.AI.ANTHROPIC_BASE_URL}${API_ENDPOINTS.ANTHROPIC_MESSAGES}`,
        {
          method: 'POST',
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
          body: JSON.stringify({
            model: config.AI.ANTHROPIC_MODEL,
            max_tokens: 200,
            messages: [
              {
                role: 'user',
                content: prompt,
              },
            ],
          }),
        },
        {
          timeout: config.REQUEST.TIMEOUT,
          maxAttempts: config.REQUEST.RETRY_ATTEMPTS,
          onRetry: (attempt, error) => {
            devLog(`Retrying Anthropic API request (attempt ${attempt})`);
          },
        }
      );
      return data.content[0].text;
    } catch (error) {
      const userMessage = handleApiError(error);
      throw new Error(userMessage);
    }
  }

  // Get advice from OpenAI
  private async getOpenAIAdvice(prompt: string): Promise<string> {
    const config = getAPIConfig(this.developerApiKey);
    const apiKey = config.AI.OPENAI_API_KEY;
    if (!apiKey) {
      throw new Error(API_ERRORS.NO_API_KEY);
    }

    try {
      const data = await fetchJsonWithRetry<any>(
        `${config.AI.OPENAI_BASE_URL}${API_ENDPOINTS.OPENAI_COMPLETIONS}`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${apiKey}`,
          },
          body: JSON.stringify({
            model: config.AI.OPENAI_MODEL,
            messages: [
              {
                role: 'system',
                content: 'You are a professional squash coach providing brief, actionable advice.',
              },
              {
                role: 'user',
                content: prompt,
              },
            ],
            max_tokens: 200,
            temperature: 0.7,
          }),
        },
        {
          timeout: config.REQUEST.TIMEOUT,
          maxAttempts: config.REQUEST.RETRY_ATTEMPTS,
          onRetry: (attempt, error) => {
            devLog(`Retrying OpenAI API request (attempt ${attempt})`);
          },
        }
      );
      return data.choices[0].message.content;
    } catch (error) {
      const userMessage = handleApiError(error);
      throw new Error(userMessage);
    }
  }

  // Cache management
  private async getCachedAdvice(data: TrainingData): Promise<AIResponse | null> {
    try {
      const cached = await AsyncStorage.getItem(this.cacheKey);
      if (!cached) return null;

      const cachedData = JSON.parse(cached);
      const cacheAge = Date.now() - cachedData.timestamp;

      // Check if cache is still valid
      const config = getAPIConfig(this.developerApiKey);
      if (cacheAge < config.REQUEST.CACHE_DURATION) {
        // Simple comparison - in production, use better hashing
        const dataKey = JSON.stringify(data);
        if (cachedData.dataKey === dataKey) {
          return cachedData.response;
        }
      }
    } catch (error) {
      devError('Cache read error:', error);
    }
    return null;
  }

  private async cacheAdvice(data: TrainingData, response: AIResponse): Promise<void> {
    try {
      const cacheData = {
        dataKey: JSON.stringify(data),
        response,
        timestamp: Date.now(),
      };
      await AsyncStorage.setItem(this.cacheKey, JSON.stringify(cacheData));
    } catch (error) {
      devError('Cache write error:', error);
    }
  }

  // Quick tips without full analysis
  async getQuickTip(skillLevel: string): Promise<string> {
    const tips = {
      beginner: [
        'Focus on your grip - maintain a firm but relaxed hold on the racket.',
        'Keep your eye on the ball through the entire swing.',
        'Practice your footwork - good positioning is key to solid shots.',
      ],
      intermediate: [
        'Work on varying your shot placement to keep opponents guessing.',
        'Develop your drop shot - it\'s a crucial weapon in squash.',
        'Focus on controlling the T-position during rallies.',
      ],
      advanced: [
        'Analyze your opponent\'s patterns and exploit their weaknesses.',
        'Perfect your deception - disguise your shots better.',
        'Work on shot selection under pressure situations.',
      ],
    };

    const levelTips = tips[skillLevel as keyof typeof tips] || tips.beginner;
    return levelTips[Math.floor(Math.random() * levelTips.length)];
  }
}

export default new AIApiService();