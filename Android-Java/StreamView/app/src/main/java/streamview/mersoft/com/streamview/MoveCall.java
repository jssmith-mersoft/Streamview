package streamview.mersoft.com.streamview;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mersoft.move.MoveClient;
import com.mersoft.move.MoveListener;

import org.webrtc.AudioTrack;
import org.webrtc.EglBase;
import org.webrtc.RendererCommon.ScalingType;
import org.webrtc.SurfaceViewRenderer;
import org.webrtc.VideoRenderer;
import org.webrtc.VideoTrack;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class MoveCall extends Activity {
    final static String TAG = "CallActivity";

    MoveClient moveClient;

    LinearLayout remoteViewsParent;
    ImageButton hangupBtn;
    ImageButton cameraBtn;
    ImageButton muteBtn;
    ImageButton remoteMuteBtn;
    boolean muteState = true;
    boolean remoteMuteState = true;
    private EglBase rootEglBase;

    //MoveClient.ProxyRenderer localRender;
    //VideoRenderer localRenderer;
    //VideoTrack localTrack;
    //SurfaceViewRenderer pipRenderer;

    String returnedCallId;


    class Renderers{
        SurfaceViewRenderer viewRenderer;
        MoveClient.ProxyRenderer callbacks;
        VideoRenderer renderer;
    }

    HashMap<String, Renderers> remoteRenderers = new HashMap<String, Renderers>();
    List<SurfaceViewRenderer> remoteRendererViews = new ArrayList<SurfaceViewRenderer>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.d(TAG, "On create!");

        String contactID = this.getIntent().getStringExtra("contact");
        final String callID = this.getIntent().getStringExtra("callID");
        boolean owner = this.getIntent().getBooleanExtra("Owner", false);
        final String cid = this.getIntent().getStringExtra("cid");
        final String operation = this.getIntent().getStringExtra("operation");

        setContentView(R.layout.call);
        
        remoteViewsParent = (LinearLayout) findViewById(R.id.parent);

        rootEglBase = EglBase.create();
        /*
        pipRenderer = (SurfaceViewRenderer) findViewById(R.id.pip_video_view);
        pipRenderer.init(rootEglBase.getEglBaseContext(), null);
        pipRenderer.setScalingType(ScalingType.SCALE_ASPECT_FIT);
        pipRenderer.setZOrderOnTop(true);
        pipRenderer.setEnableHardwareScaler(true);
        pipRenderer.setMirror(true);
        */

        moveClient = StreamView.getMoveClient();
        moveClient.setEglBase(rootEglBase.getEglBaseContext());

        Log.d(TAG, "Set activity");

        MoveClient.VideoTrackCallback onAdd = new MoveClient.VideoTrackCallback() {
            @Override
            public void onLocalTrack(VideoTrack track) {
                /*
                if(localRender == null){
                    localRender = new MoveClient.ProxyRenderer();
                    localRenderer = new VideoRenderer(localRender);
                }
                if(localTrack == null) {
                    localTrack = track;
                    track.addRenderer(localRenderer);
                    localRender.setTarget(pipRenderer);
                }
                */
            }

            @Override
            public void onRemoteTrack(final String callId, final String peerId, final VideoTrack track) {
                runOnUiThread(new Runnable() {
                    public void run() {
                        Renderers newRenderer = new Renderers();
                        remoteRenderers.put(callId + ":" + peerId, newRenderer);
                        newRenderer.callbacks = new MoveClient.ProxyRenderer();
                        newRenderer.viewRenderer = createNewRemote();
                        newRenderer.renderer = new VideoRenderer(newRenderer.callbacks);
                        track.addRenderer(newRenderer.renderer);
                        newRenderer.callbacks.setTarget(newRenderer.viewRenderer);
                        remoteViewsParent.addView(newRenderer.viewRenderer);

                        //default it as off.
                        muteState = false;
                        moveClient.mute(muteState);
                        muteBtn.setImageResource(R.drawable.ic_mic_off);
                    }
                });
            }
        };

        MoveClient.VideoTrackCallback onRemove = new MoveClient.VideoTrackCallback() {
            @Override
            public void onLocalTrack(VideoTrack track) {
                //track.removeRenderer(localRenderer);
            }

            @Override
            public void onRemoteTrack(final String callId, final String peerId, final VideoTrack track) {
                runOnUiThread(new Runnable() {
                    public void run() {
                        Renderers removedRenderer = remoteRenderers.remove(callId + ":" + peerId);
                        if(removedRenderer != null){
                            remoteViewsParent.removeView(removedRenderer.viewRenderer);
                            resizeRemote();
                        }
                    }
                });
            }
        };

        moveClient.setVideoTrackCallbacks(onAdd, onRemove);

        moveClient.hangupCallback = new MoveClient.Callback() {
            @Override
            public void onSuccess() {
                //Intent i = new Intent(StreamView.getAppContext(), MainStreamViewActivity.class);
                //startActivity(i);
            }

            @Override
            public void onFailure() {

            }
        };

        moveClient.addListener(new MoveListener() {
            @Override
            public void onCallId(String callId, String peerId){
                returnedCallId = callId;
            }
        });

        if (operation.equals("call")){
            moveClient.sendVideo = false;
            moveClient.sendAudio = true;
            moveClient.receiveVideo = true;
            moveClient.receiveAudio = true;

            moveClient.placeCall(contactID, "TN", new MoveClient.Callback() {
                @Override
                public void onSuccess() {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            hangupBtn.setEnabled(true);
                        }
                    });
                }

                @Override
                public void onFailure() {

                }
            });
        } else if(operation.equals("accept_call")) {
            Log.d(TAG, "Answering call from: " + callID);
            moveClient.acceptCall(callID);
        }

        hangupBtn = (ImageButton) findViewById(R.id.hangup_btn);
        hangupBtn.setEnabled(true);
        hangupBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                runOnUiThread(new Runnable() {
                    public void run() {
                        Log.d(TAG,"the Hangup button pressed");
                        for(SurfaceViewRenderer rendererView : remoteRendererViews) {
                            remoteViewsParent.removeView(rendererView);
                            resizeRemote();
                        }
                        remoteRenderers.clear();
                    }
                });


                moveClient.hangupCall(callID != null ? callID : returnedCallId);
            }
        });

        muteBtn = (ImageButton) findViewById(R.id.mute_btn);
        muteBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                muteState = !muteState;
                moveClient.mute(muteState);
                if (muteState) {
                    muteBtn.setImageResource(R.drawable.ic_mic_on);
                } else {
                    muteBtn.setImageResource(R.drawable.ic_mic_off);
                }
            }
        });

        remoteMuteBtn = (ImageButton) findViewById(R.id.remote_mute_btn);
        remoteMuteBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                remoteMuteState = !remoteMuteState;
                moveClient.muteRemote(callID != null ? callID : returnedCallId, remoteMuteState);
                if (remoteMuteState) {
                    remoteMuteBtn.setImageResource(R.drawable.ic_speaker_off);
                } else {
                    remoteMuteBtn.setImageResource(R.drawable.ic_speaker_on);
                }
            }
        });

        //

    }

    public SurfaceViewRenderer createNewRemote(){
        SurfaceViewRenderer renderer = new SurfaceViewRenderer(this);
        remoteRendererViews.add(renderer);
        resizeRemote();
        renderer.init(rootEglBase.getEglBaseContext(), null);
        renderer.setScalingType(ScalingType.SCALE_ASPECT_FILL);
        renderer.setEnableHardwareScaler(true);
        return renderer;
    }

    //Resizes remote views to fit page
    public void resizeRemote(){
        for(SurfaceViewRenderer rendererView : remoteRendererViews){
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, remoteViewsParent.getHeight() / (remoteRenderers.size() == 0 ? 1 : remoteRenderers.size()));
            rendererView.setLayoutParams(params);
        }
    }

}