package streamview.mersoft.com.streamview;

import android.content.Context;
import android.util.Log;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.FirebaseInstanceIdService;
import com.mersoft.move.MoveClient;

public class MoveFireBaseService extends FirebaseInstanceIdService {
    final static String TAG = "MoveFireBaseService";

    public MoveFireBaseService() {
    }

    @Override
    public void onTokenRefresh() {
        // Get updated InstanceID token.
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        Log.d(TAG, "Refreshed token: " + refreshedToken);

        // If you want to send messages to this application instance or
        // manage this apps subscriptions on the server side, send the
        // Instance ID token to your app server.

        final MoveClient moveClient = StreamView.getMoveClient();
        if (moveClient.isRegistered()) {
            moveClient.setToken(refreshedToken);
        }

        getSharedPreferences("_", MODE_PRIVATE).edit().putString("fb", refreshedToken).apply();
    }

    public static String getToken(Context context) {
        return context.getSharedPreferences("_", MODE_PRIVATE).getString("fb", "empty");
    }
}
