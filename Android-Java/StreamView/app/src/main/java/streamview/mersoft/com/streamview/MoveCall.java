package streamview.mersoft.com.streamview;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.SystemClock;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mersoft.move.MoveClient;
import com.mersoft.move.MoveListener;

import org.webrtc.EglBase;
import org.webrtc.SurfaceViewRenderer;
import org.webrtc.VideoRenderer;
import org.webrtc.VideoTrack;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

public class MoveCall extends AppCompatActivity {
    final static String TAG = "CallActivity";

    MoveClient moveClient;
    Activity currentActivity;
    LinearLayout remoteViewsParent;
    ImageButton hangupBtn;
    ImageButton cameraBtn;
    ImageButton muteBtn;
    ImageButton remoteMuteBtn;
    ImageButton sirenBtn;
    ImageButton rotateBtn;
    ImageButton settingBtn;
    TextView startTimerView;
    TextView callTimerView;
    boolean muteState = true;
    boolean remoteMuteState = true;
    private EglBase rootEglBase;
    private long startTime;
    boolean firstFame = false;



    String deviceID;
    int currentRotation = 0;
    String name;
    boolean sirenPlaying = false;

    private ScaleGestureDetector mScaleGestureDetector;


    //MoveClient.ProxyRenderer localRender;
    //VideoRenderer localRenderer;
    //VideoTrack localTrack;
    //SurfaceViewRenderer pipRenderer;

    String returnedCallId;
    private Timer clocktimer;


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

        currentActivity = this;
        //LocalBroadcastManager lbm = LocalBroadcastManager.getInstance(this);
        //lbm.registerReceiver(receiver, new IntentFilter("Hangup"));

        String contactID = this.getIntent().getStringExtra("contact");
        deviceID = contactID;
        final String callID = this.getIntent().getStringExtra("callID");
        boolean owner = this.getIntent().getBooleanExtra("Owner", false);
        final String cid = this.getIntent().getStringExtra("cid");
        currentRotation = this.getIntent().getIntExtra("rotation",0);
        name = this.getIntent().getStringExtra("name");
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
        mScaleGestureDetector = new ScaleGestureDetector(this, new ScaleListener());

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

                        firstFame = true;

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
                        Log.d(TAG,"Removing the track from the view");
                        if(removedRenderer != null){
                            remoteViewsParent.removeView(removedRenderer.viewRenderer);
                            Log.d(TAG,"Removed view");
                            //resizeRemote();
                        }
                    }
                });
            }
        };

        moveClient.setVideoTrackCallbacks(onAdd, onRemove);

        moveClient.addListener(new MoveListener() {
            @Override
            public void onCallId(String callId, String peerId){
                returnedCallId = callId;
            }
            @Override
            public void onHangup(String callID) {
                currentActivity.finish();
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
            startTimerView = (TextView) findViewById(R.id.start_timer);
            callTimerView = (TextView)findViewById(R.id.call_timer);
            startClock();
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
                            //resizeRemote();
                        }
                        remoteRenderers.clear();
                    }
                });

                stopClock();
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

        sirenBtn = (ImageButton) findViewById(R.id.siren_btn);
        sirenBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
               //call move to turn on siren
               if (deviceID != null && deviceID != "") {
                   if (sirenPlaying) {
                       moveClient.createEvent("PlaySiren", deviceID);
                       sirenPlaying = true;
                       sirenBtn.setImageResource(R.drawable.ic_speaker_off);

                       new Handler().postDelayed(new Runnable() {
                           @Override
                           public void run() {
                               sirenPlaying = false;
                               sirenBtn.setImageResource(android.R.drawable.ic_dialog_alert);
                           }
                       }, 5000);
                   } else {
                       moveClient.createEvent("StopSiren",deviceID);
                       sirenBtn.setImageResource(android.R.drawable.ic_dialog_alert);
                   }
               }
            }
        });

        rotateBtn = (ImageButton) findViewById(R.id.rotate_btn);
        rotateBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //call move to turn to rotate
                if (deviceID != null && deviceID != "") {
                    Map<String, String> setDebug = new HashMap<String, String>();
                    setDebug.put("debug", "true");
                    setDebug.put("imageFlip", String.valueOf(currentRotation));
                    moveClient.updateConfig(deviceID,setDebug);
                }
            }
        });

        settingBtn = (ImageButton) findViewById(R.id.setting_btn);
        settingBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                SettingDialog settingDialog =  new SettingDialog();
                settingDialog.show(getSupportFragmentManager(), "setting dialog");
            }
        });
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG,"onStop");
    }

    @Override
    protected void onDestroy() {
        Log.d(TAG,"onDestroy");
        super.onDestroy();
    }

    @Override
    public boolean onTouchEvent(MotionEvent motionEvent) {
        // Dispatch activity on touch event to the scale gesture detector.
        mScaleGestureDetector.onTouchEvent(motionEvent);
        return true;
    }

    public SurfaceViewRenderer createNewRemote(){
        //SurfaceViewRenderer renderer = new SurfaceViewRenderer(this);
        SurfaceViewRenderer renderer = new SurfaceViewRenderer(getApplicationContext());
        remoteRendererViews.add(renderer);
        //resizeRemote();
        renderer.init(rootEglBase.getEglBaseContext(), null);
        //renderer.setScalingType(RendererCommon.ScalingType.SCALE_ASPECT_FIT);
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

    public void startClock() {
        clocktimer = new Timer();
        this.startTime = SystemClock.uptimeMillis();
        TimerTask updateTask = new TimerTask() {

            @Override
            public void run() {
                int Seconds, Minutes, MilliSeconds,Hour;
                long MillisecondTime = SystemClock.uptimeMillis() - startTime;

                Seconds = (int) (MillisecondTime / 1000);
                Minutes = Seconds / 60;
                Seconds = Seconds % 60;
                MilliSeconds = (int) (MillisecondTime % 1000);
                Hour = Minutes / 60;
                Minutes = Minutes % 60;

                String counter = String.format("%02d:%02d:%02d:%03d",Hour,Minutes,Seconds,MilliSeconds);
                runOnUiThread(new Runnable() {
                    public void run() {
                        if (!firstFame) {
                            startTimerView.setText(counter);
                        }
                        callTimerView.setText(counter);
                    }
                });

                //Log.d(TAG,"timer - "+counter);
            };
        };

        clocktimer.schedule(updateTask, 1, 100);
    }

    public void stopClock() {
        if(clocktimer != null){
            clocktimer.cancel();
            clocktimer.purge();
        }
    }

    public void setDeviceID(String deviceID) {
        this.deviceID = deviceID;
    }

    public void setCurrentRotation(int currentRotation) {
        this.currentRotation = currentRotation;
    }

    public void setName(String name) {
        this.name = name;
    }

    private class ScaleListener extends ScaleGestureDetector.SimpleOnScaleGestureListener {

        private float mScaleFactor = 1.0f;

        @Override
        public boolean onScale(ScaleGestureDetector scaleGestureDetector){
            mScaleFactor *= scaleGestureDetector.getScaleFactor();
            mScaleFactor = Math.max(0.1f, Math.min(mScaleFactor, 10.0f));

            Iterator it = remoteRenderers.entrySet().iterator();
            while (it.hasNext()) {
                Map.Entry pair = (Map.Entry) it.next();
                Renderers videoRender = (Renderers) pair.getValue();

                if (videoRender.viewRenderer != null) {
                    videoRender.viewRenderer.setScaleX(mScaleFactor);
                    videoRender.viewRenderer.setScaleY(mScaleFactor);
                }
            }
            return true;
        }
    }
}
