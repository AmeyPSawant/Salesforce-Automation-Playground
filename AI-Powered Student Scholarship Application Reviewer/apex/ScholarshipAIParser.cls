public class ScholarshipAIParser {
    
    public class AIAnalysisResult {
        @InvocableVariable(required=true)
        public Integer score;
        
        @InvocableVariable(required=true)
        public String recommendation;
        
        @InvocableVariable(required=true)
        public String strengths;
        
        @InvocableVariable(required=true)
        public String concerns;
        
        @InvocableVariable(required=true)
        public String reasoning;
    }
    
    public class Request {
        @InvocableVariable(required=true label='AI Raw Response')
        public String aiRawResponse;
    }
    
    @InvocableMethod(label='Parse AI Analysis Response' description='Extracts score, recommendation, and other fields from Hugging Face API response')
    public static List<AIAnalysisResult> parseAIResponse(List<Request> requests) {
        List<AIAnalysisResult> results = new List<AIAnalysisResult>();
        
        for (Request req : requests) {
            AIAnalysisResult result = new AIAnalysisResult();
            
            try {
                // Parse the outer JSON
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(req.aiRawResponse);
                
                // Get the choices array
                List<Object> choices = (List<Object>) responseMap.get('choices');
                Map<String, Object> firstChoice = (Map<String, Object>) choices[0];
                Map<String, Object> message = (Map<String, Object>) firstChoice.get('message');
                String content = (String) message.get('content');
                
                // Clean up the content (remove markdown code blocks)
                content = content.replace('```json', '').replace('```', '').trim();
                
                // Parse the inner JSON (the actual AI analysis)
                Map<String, Object> analysis = (Map<String, Object>) JSON.deserializeUntyped(content);
                
                // Extract score
                result.score = analysis.get('score') != null ? Integer.valueOf(analysis.get('score')) : 60;
                
                // Extract recommendation
                result.recommendation = (String) analysis.get('recommendation');
                if (result.recommendation == null) {
                    result.recommendation = 'MANUAL_REVIEW';
                }
                
                // Extract strengths (handle both String and List)
                result.strengths = formatField(analysis.get('strengths'));
                
                // Extract concerns (handle both String and List)
                result.concerns = formatField(analysis.get('concerns'));
                
                // Extract reasoning
                result.reasoning = (String) analysis.get('reasoning');
                if (result.reasoning == null) {
                    result.reasoning = 'No reasoning provided by AI';
                }
                
            } catch (Exception e) {
                // If parsing fails, return safe defaults
                result.score = 60;
                result.recommendation = 'MANUAL_REVIEW';
                result.strengths = 'Unable to parse AI strengths. Manual review required.';
                result.concerns = 'Error parsing response: ' + e.getMessage();
                result.reasoning = 'Manual review required due to parsing error';
                
                System.debug('Error parsing AI response: ' + e.getMessage());
            }
            
            results.add(result);
        }
        
        return results;
    }
    
    // Helper method to format field - handles both String and List<Object>
    private static String formatField(Object fieldValue) {
        if (fieldValue == null) {
            return 'Not provided';
        }
        
        // If it's already a string, return it
        if (fieldValue instanceof String) {
            return (String) fieldValue;
        }
        
        // If it's a list, format with bullet points
        if (fieldValue instanceof List<Object>) {
            List<Object> items = (List<Object>) fieldValue;
            List<String> formattedItems = new List<String>();
            
            for (Object item : items) {
                if (item != null) {
                    formattedItems.add('• ' + String.valueOf(item));
                }
            }
            
            return String.join(formattedItems, '\n');
        }
        
        // Fallback: convert to string
        return String.valueOf(fieldValue);
    }
}