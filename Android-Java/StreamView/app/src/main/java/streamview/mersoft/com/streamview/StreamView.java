package streamview.mersoft.com.streamview;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.mersoft.move.MoveClient;
import com.mersoft.move.MoveListener;

/**
 * Created by MattJahnke on 10/27/16.
 */
public class StreamView extends Application {
    static final String TAG = "StreamView";
    private static MoveClient moveClient;
    private static Context appContext;
    private static Activity currentActivity;


    static public MoveClient getMoveClient(){
        return moveClient;
    }

    static public Context getAppContext(){ return appContext;}

    static public void setMoveClient(MoveClient client){
        moveClient = client;
    }

    static public void initializeMoveClient(){
        moveClient = new MoveClient();
        moveClient.addListener(new MoveListener() {
            @Override
            public void onPromptForAnswerCall(String call, String contact) {
                Log.d(TAG, "onPromptForAnswerCall");
                Log.d(TAG, "Answering call: " + call + " from contact: " + contact);
                Intent intent = new Intent("MoveCall");
                intent.putExtra("contact", contact);
                intent.putExtra("callID", call);
                LocalBroadcastManager.getInstance(getAppContext()).sendBroadcast(intent);
            }

            @Override
            public void onHangup(String callID) {
                Log.d(TAG, "Hanging up call: " + callID );

                Intent intent = new Intent("Hangup");
                intent.getStringExtra(callID);
                LocalBroadcastManager.getInstance(getAppContext()).sendBroadcast(intent);
            }

            @Override
            public void videoFrozen(Boolean isFrozen, String peerId, String client) {
                Log.d(TAG, "Got video frozen notification status: " + isFrozen);
            }

            @Override
            public void audioMuted(Boolean isMuted, String peerId, String client) {
                Log.d(TAG, "Got audio muted notification status: " + isMuted);
            }


        });

    }

    public void onCreate() {
        super.onCreate();

        appContext = getApplicationContext();

        initializeMoveClient();
    }

}
