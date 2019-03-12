package streamview.mersoft.com.streamview;

import android.app.Activity;
import android.media.AudioManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.SystemClock;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mersoft.move.MoveClient;
import com.mersoft.move.MoveListener;

import org.webrtc.EglBase;
import org.webrtc.SurfaceViewRenderer;
import org.webrtc.RendererCommon.ScalingType;
import org.webrtc.VideoSink;
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
    //LinearLayout remoteViewsParent;
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

    //MoveClient.ProxyRenderer localRender;
    //VideoRenderer localRenderer;
    //VideoTrack localTrack;
    //SurfaceViewRenderer pipRenderer;

    String returnedCallId;
    private Timer clocktimer;


    class Renderers{
        SurfaceViewRenderer viewRenderer;
        MoveClient.ProxyVideoSink callbacks;
        VideoSink renderer;
    }

    HashMap<String, Renderers> remoteRenderers = new HashMap<String, Renderers>();

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
        
        //remoteViewsParent = (LinearLayout) findViewById(R.id.parent);

        rootEglBase = EglBase.create();
        /*
        pipRenderer = (SurfaceViewRenderer) findViewById(R.id.pip_video_view);
        pipRenderer.init(rootEglBase.getEglBaseContext(), null);
        pipRenderer.setScalingType(ScalingType.SCALE_ASPECT_FIT);
        pipRenderer.setZOrderOnTop(true);
        pipRenderer.setEnableHardwareScaler(true);
        pipRenderer.setMirror(true);
        */

        AudioManager audioManager =
                ((AudioManager) this.getSystemService(this.AUDIO_SERVICE));
        boolean isWiredHeadsetOn = audioManager.isWiredHeadsetOn();
        audioManager.setMode(isWiredHeadsetOn ?
                AudioManager.MODE_IN_CALL : AudioManager.MODE_IN_COMMUNICATION);
        audioManager.setSpeakerphoneOn(!isWiredHeadsetOn);

        moveClient = StreamView.getMoveClient();
        moveClient.setEglBase(rootEglBase.getEglBaseContext());

        Log.d(TAG, "Set activity");

        MoveClient.VideoTrackCallback onAdd = new MoveClient.VideoTrackCallback() {
            @Override
            public void onLocalTrack(VideoTrack track) {
                Log.d(TAG,"Adding local view");
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
                        Log.d(TAG,"Adding view");
                        Renderers newRenderer = new Renderers();
                        remoteRenderers.put(callId + ":" + peerId, newRenderer);
                        newRenderer.callbacks = new MoveClient.ProxyVideoSink(){
                           @Override
                           public void firstFame() {
                                firstFame = true;
                           }
                        };
                        //newRenderer.viewRenderer =  new SurfaceViewRenderer(getApplicationContext());
                        newRenderer.viewRenderer = (SurfaceViewRenderer) findViewById(R.id.remoteView);
                        newRenderer.viewRenderer.setScalingType(ScalingType.SCALE_ASPECT_FILL);
                        //newRenderer.viewRenderer.setScalingType(ScalingType.SCALE_ASPECT_FIT);
                        newRenderer.viewRenderer.init(rootEglBase.getEglBaseContext(), null);
                        newRenderer.viewRenderer.setEnableHardwareScaler(false);
                        newRenderer.callbacks.setTarget(newRenderer.viewRenderer);
                        //remoteViewsParent.addView(newRenderer.viewRenderer);
                        track.addSink(newRenderer.callbacks);


                        //Mute Mic
                        moveClient.mute(true);
                        muteState = false;
                        muteBtn.setImageResource(R.drawable.ic_mic_off);

                        //Mute Stream from Camera
                        moveClient.muteRemote(callId, remoteMuteState);
                        remoteMuteBtn.setImageResource(R.drawable.ic_speaker_off);
                    }
                });
            }
        };


        MoveClient.VideoTrackCallback onRemove = new MoveClient.VideoTrackCallback() {
            @Override
            public void onLocalTrack(VideoTrack track) {
                //Log.d(TAG,"removing local view");
                //track.removeRenderer(localRenderer);
            }

            @Override
            public void onRemoteTrack(final String callId, final String peerId, final VideoTrack track) {

                Renderers removedRenderer = remoteRenderers.remove(callId + ":" + peerId);
                Log.d(TAG,"Removing the track from the view");
                if(removedRenderer != null) {
                    //runOnUiThread(new Runnable() {
                    //    public void run() {

                            //Log.d(TAG, "removing the view ");
                            //remoteViewsParent.removeView(removedRenderer.viewRenderer);


                            Log.d(TAG, "clearing the sync target");
                            removedRenderer.callbacks.setTarget(null);
                            track.removeSink(removedRenderer.callbacks);


                            Log.d(TAG, "releasing the reneder ");
                            if (rootEglBase.hasSurface()) {
                                Log.d(TAG, "has a surface connected ot the EglBase");
                                rootEglBase.releaseSurface();
                            } else {
                                Log.d(TAG, "NO surface connected ot the EglBase");
                            }

                            removedRenderer.viewRenderer.release();
                            removedRenderer.viewRenderer = null;

                            //resizeRemote();
                  //      }
                  //  });
                }
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
                Log.d(TAG, "OnHangup CAllback is called "+callID);
                if (rootEglBase.hasSurface()) {
                    Log.d(TAG, "has surface "+callID);
                    rootEglBase.release();
                }

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

                        /*
                        Iterator it = remoteRenderers.entrySet().iterator();
                        while (it.hasNext()) {
                            Map.Entry pair = (Map.Entry) it.next();
                            Renderers videoRender = (Renderers) pair.getValue();

                            Log.d(TAG, "removing render: " + videoRender.viewRenderer);
                            try {
                                if (videoRender.viewRenderer != null) {
                                    remoteViewsParent.removeView(videoRender.viewRenderer);
                                }
                                //resizeRemote();
                            } catch (Exception e) {
                                Log.d(TAG, "excepton in call: " + e.toString());
                            }
                        }
                        //Log.d(TAG, "clear remoteRenders");
                        //remoteRenderers.clear();
                        Log.d(TAG, "done with cleanup renderView ");
                        */
                    }
                });

                stopClock();
                moveClient.hangupCall(callID != null ? callID : returnedCallId);
                Log.d(TAG, "done with onHangup Click ");
            }
        });

        muteBtn = (ImageButton) findViewById(R.id.mute_btn);
        muteBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                moveClient.mute(muteState);
                muteState = !muteState;
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
                   if (!sirenPlaying) {
                       moveClient.createEvent("PlaySiren", deviceID);
                       sirenPlaying = true;
                       //sirenBtn.setImageResource(R.drawable.ic_speaker_off);
                       sirenBtn.setImageResource(R.drawable.ic_siren_off);
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
                currentRotation = currentRotation+1;
                if (currentRotation > 3) currentRotation = 0;
                if (deviceID != null && deviceID != "") {
                    Map<String, String> setFlip = new HashMap<String, String>();
                    //setDebug.put("debug", "true");
                    setFlip.put("imageFlip", String.valueOf(currentRotation));
                    moveClient.updateConfig(deviceID,setFlip);
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
        return true;
    }


    //Resizes remote views to fit page
    public void resizeRemote(){
        /*
        Iterator it = remoteRenderers.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry pair = (Map.Entry) it.next();
            Renderers videoRender = (Renderers) pair.getValue();

            if (videoRender.viewRenderer != null) {
                LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, remoteViewsParent.getHeight() / (remoteRenderers.size() == 0 ? 1 : remoteRenderers.size()));
                videoRender.viewRenderer.setLayoutParams(params);
            }
        }
        */
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
}
