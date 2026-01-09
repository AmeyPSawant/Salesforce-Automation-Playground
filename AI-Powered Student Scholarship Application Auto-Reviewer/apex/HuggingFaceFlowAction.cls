public with sharing class HuggingFaceFlowAction {

    public class Request {
        @InvocableVariable(required=true)
        public String prompt;
    }

    public class Response {
        @InvocableVariable
        public String response;
    }

    @InvocableMethod(label='Call Hugging Face AI')
    public static List<Response> callHuggingFace(List<Request> requests) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            'callout:HuggingFaceCred/v1/chat/completions'
        );
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> body = new Map<String, Object>{
            'model' => 'meta-llama/Llama-3.1-8B-Instruct',
            'messages' => new List<Object>{
                new Map<String, Object>{
                    'role' => 'user',
                    'content' => requests[0].prompt
                }
            },
            'max_tokens' => 500,
            'temperature' => 0.7
        };

        req.setBody(JSON.serialize(body));

        Http http = new Http();
        HttpResponse res = http.send(req);

        Response r = new Response();
        r.response = res.getBody();

        return new List<Response>{ r };
    }
}