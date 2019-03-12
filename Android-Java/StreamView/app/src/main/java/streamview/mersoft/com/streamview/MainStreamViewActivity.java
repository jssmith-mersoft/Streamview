package streamview.mersoft.com.streamview;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.mersoft.move.MoveClient;
import com.mersoft.move.MoveDevice;
import com.mersoft.move.MoveListener;
import com.mersoft.move.MoveRegistration;
import com.mersoft.move.MoveService;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;



public class MainStreamViewActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener {

    public static int counter = 0;

    final static String TAG = "MainStreamViewActivity";
    DrawerLayout drawer;
    NavigationView navigationView;
    Toolbar toolbar;
    Map<String,String> imageURLs;
    Map<String,Bitmap> thumbnails;
    ArrayList<String> cameraIDs;
    MoveListener callbacks;
    GridView gv;
    GridAdapter gridviewAdpt;
    boolean visiible;

    private Timer thumbNailLoaderTimer1;
    private TimerTask mThumbNailLoaderTt1;
    private Handler mThumbNailLoaderHandler = new Handler();

    private Timer thbUrlLoaderTimer1;
    private TimerTask thbUrlLoaderTt1;
    private Handler thbUrlLoaderHandler = new Handler();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        visiible = true;
        counter++;
        setContentView(R.layout.activity_main_stream_view);
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        /*
        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startCall("ABC");
            }
        });
        */

        drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();

        navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);


        imageURLs = new HashMap<String,String>();
        thumbnails = new HashMap<String,Bitmap>();
        cameraIDs = new ArrayList<String>();

        LinearLayout viewContents = (LinearLayout) findViewById(R.id.viewContent);

        //create the gridview
        gv = new GridView(this);
        gv.setId(R.id.previewGridView);
        gv.setLayoutParams(new GridView.LayoutParams(GridView.LayoutParams.MATCH_PARENT,GridView.LayoutParams.MATCH_PARENT));
        gv.setBackgroundColor(Color.WHITE);
        gv.setNumColumns(1);
        gv.setColumnWidth(GridView.AUTO_FIT);
        gv.setVerticalSpacing(5);
        gv.setHorizontalSpacing(5);
        gv.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);

        gridviewAdpt = new GridAdapter();
        gridviewAdpt.mContext = this;
        gv.setAdapter(gridviewAdpt);
        viewContents.addView(gv);

        MoveClient moveClient = StreamView.getMoveClient();
        moveClient.setContext(getApplicationContext());
        callbacks = new MoveListener();
        moveClient.addListener(new MoveListener() {
            @Override
            public void cameraThumbnailURLReceived(String url, String deviceID){
                Log.d(TAG, "Got URL for camera");
                imageURLs.put(deviceID, url);
                new LoadImagefromUrl().execute(deviceID);
            }

            @Override
            public void notificationReceived(Map data){
                Log.d(TAG, "Recevied Notification");
            };

            @Override
            public void retrieveEventHistory(Map data){
                Log.d(TAG, "retrieveEventHistory");
            };

            @Override
            public void onConfigChange(Map<String,Object> data, String deviceID){
                Log.d(TAG, "onConfigChange");
            };

            @Override
            public void onConfigReceived(MoveDevice data, String deviceID){
                Log.d(TAG, "onConfigReceived");
            };

            @Override
            public void RecordVideoEvent(String imageURL,String videoURL, String deviceID){
                Log.d(TAG, "RecordVideoEvent");
            };

            @Override
            public void StopRecordVideoEvent(String deviceID){
                Log.d(TAG, "RecordVideoEvent");
            };

            @Override
            public void SnapShotEvent(String url, String deviceID){
                Log.d(TAG, "SnapShotEvent");
            };

            @Override
            public void PlaySirenEvent(String deviceID){
                Log.d(TAG, "PlaySirenEvent");
            };

            @Override
            public void StopPlaySirenEvent(String deviceID){
                Log.d(TAG, "StopPlaySirenEvent");
            };

            @Override
            public void onPromptForAnswerCall(String callId, String contact) {
                Log.d("DEMO", "onPromptForAnswerCall");
                Log.d("DEMO", "Answering call: " + callId + " from contact: " + contact);
                Intent i = new Intent(StreamView.getAppContext(), MoveCall.class);
                i.putExtra("operation", "accept_call");
                i.putExtra("contact", contact);
                i.putExtra("callID", callId);
                i.putExtra("deviceID", "");
                i.putExtra("name", "");
                i.putExtra("rotation", "");
                startActivity(i);
            }

            @Override
            public void addDevice(MoveDevice data, String deviceID){
                Log.d("DEMO", "addDevice for new deivce "+deviceID);

                // Update the devices array to get images for new device
                cameraIDs.add(deviceID);
            }

            @Override
            public void addDeviceFail(String cameraID, String errorMessage){
                Log.d("DEMO", "addDeviceFail for camera "+cameraID+" with error "+errorMessage);
            }


/*
            @Override
            public void onHangup(String callID) {
                Intent i = new Intent(StreamView.getAppContext(), MainStreamViewActivity.class);
                StreamView.getAppContext().startActivity(i);
            }

            @Override
            public void videoFrozen(Boolean isFrozen, String peerId, String client) {
                Log.d(TAG, "Got video frozen notification status: " + isFrozen);
            }

            @Override
            public void audioMuted(Boolean isMuted, String peerId, String client) {
                Log.d(TAG, "Got audio muted notification status: " + isMuted);
            }
*/

        });

        MoveRegistration curReg = moveClient.getCurrentRegistration();
        if (curReg != null) {
            cameraIDs.clear();
            for (MoveService service : curReg.services) {
                if (service.type.equalsIgnoreCase("Camera")) {
                    String currentDeviceId = service.getCameraAddress();

                    Log.d(TAG,"starting camera"+currentDeviceId);
                    cameraIDs.add(currentDeviceId);

                    /*
                    Map<String, Boolean> data = new HashMap<String, Boolean>();
                    data.put("debug", true);
                    moveClient.updateConfig(currentDeviceId, data);
                    */

                }
            }
            startURLTimer();
            startThumbnailTimer();
        }


        //setup a timer to refresh the Grid images

        //set a onclick fo
        gv.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int position, long id) {
                //startActivities(new Intent(getApplicationContext(), ViewImage.class).putExtra("deviceID","DEVICEIDforPosition")));
                Log.d(TAG,"Clicked on image"+position+", placeing call to "+cameraIDs.get(position));

                Intent i = new Intent(StreamView.getAppContext(), MoveCall.class);
                i.putExtra("operation", "call");
                i.putExtra("contact", cameraIDs.get(position));
                i.putExtra("rotation", 0);
                i.putExtra("name", "");
                //i.putExtra("callID", callId);
                startActivity(i);
            }
        });
    }

    public class GridAdapter extends BaseAdapter {

        private Context mContext;
        private Bitmap[]mis_fotos;

        /*
        public ImageAdapter(Context c) {
            mContext = c;
        }
        */

        @Override
        public int getCount() {
            return cameraIDs.size();
        }

        @Override
        public Object getItem(int position) {
            return position;
        }

        @Override
        public long getItemId(int position) {
            return 0;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            if (convertView == null) {
                final LayoutInflater layoutInflater = LayoutInflater.from(mContext);
                convertView = layoutInflater.inflate(R.layout.linearlayout_camera, null);
            }

            final ImageView imageView = (ImageView)convertView.findViewById(R.id.imageview_thumbnail);
            final TextView nameTextView = (TextView)convertView.findViewById(R.id.camera_name);
            final TextView idTextView = (TextView)convertView.findViewById(R.id.camera_id);
            //final ImageView imageViewFavorite = (ImageView)convertView.findViewById(R.id.imageview_favorite);
           /*

                DisplayMetrics displaymetrics = new DisplayMetrics();
                getWindowManager().getDefaultDisplay()
                        .getMetrics(displaymetrics);
                int width = displaymetrics.widthPixels;
                int height = displaymetrics.heightPixels;
            */
                //imageView.setLayoutParams(new GridView.LayoutParams(width, height/3));
            imageView.setScaleType(ImageView.ScaleType.FIT_XY);
            imageView.setPadding(0, 0, 0, 0);

            //imageView.setImageBitmap(mis_fotos[position]);
            Bitmap thumbnail = thumbnails.get(cameraIDs.get(position));

            if (thumbnail != null) {
                imageView.setImageBitmap(thumbnail);
            } else {
                //set a default pic
                //imageView.setImageBitmap(null);
                imageView.setImageResource(android.R.color.transparent);
            }

            nameTextView.setText(cameraIDs.get(position));
            idTextView.setText(cameraIDs.get(position));

            return convertView;
        }
    }

    @Override
    protected void onStart() {
        super.onStart();

        // Store our shared preference
        SharedPreferences sp = getSharedPreferences("OURINFO", MODE_PRIVATE);
        SharedPreferences.Editor ed = sp.edit();
        ed.putBoolean("active", true);
        ed.commit();

        if (thbUrlLoaderTimer1 == null) {
            startThumbnailTimer();
            startURLTimer();
        }

        Log.d(TAG,"Preview Started");
    }

    @Override
    protected void onResume(){
        super.onResume();
        visiible = true;

        if (thbUrlLoaderTimer1 == null) {
            startThumbnailTimer();
            startURLTimer();
        }

        Log.d(TAG,"Preview Resumed");
    }

    @Override
    protected void onPause() {
        super.onPause();
        visiible = false;

        if (thbUrlLoaderTimer1 != null) {
            stopTimer();
        }

        Log.d(TAG,"Preview Paused");
    }

    @Override
    protected void onStop() {
        super.onStop();

        if (thbUrlLoaderTimer1 != null) {
            stopTimer();
        }


        visiible = false;

        // Store our shared preference
        SharedPreferences sp = getSharedPreferences("OURINFO", MODE_PRIVATE);
        SharedPreferences.Editor ed = sp.edit();
        ed.putBoolean("active", false);
        ed.commit();

        Log.d(TAG,"Stopped");
    }

    @Override
    public void onBackPressed() {
        Log.d(TAG,"back");
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main_stream_view, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @SuppressWarnings("StatementWithEmptyBody")
    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();

        if (id == R.id.nav_account) {
            Intent h=new Intent(MainStreamViewActivity.this,Account.class);
            startActivity(h);
        } else if (id == R.id.nav_events) {
            Intent e=new Intent(MainStreamViewActivity.this,Events.class);
            startActivity(e);
        } else if (id == R.id.nav_home) {
            //nothing to do
        } else if (id == R.id.nav_provisionQR) {
            Intent e=new Intent(MainStreamViewActivity.this,ProvisionSoftQR.class);
            startActivity(e);
        } else if (id == R.id.nav_provisionSAP) {
            Intent e=new Intent(MainStreamViewActivity.this,ProvisionSoftAP.class);
            startActivity(e);
        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }

    private class LoadImagefromUrl extends AsyncTask< Object, Void, Bitmap > {
        String deviceId;

        @Override
        protected Bitmap doInBackground( Object... params ) {
            deviceId = (String) params[0];
            String url = imageURLs.get(deviceId);
            Log.d(TAG,"URL is "+url);
            if (url == null) {
                return null;
            } else {
                return loadBitmap(url);
            }
        }

        @Override
        protected void onPostExecute( Bitmap result ) {
            super.onPostExecute( result );
            if (result != null){
                    Log.d(TAG, "The bitmap loaded into the array");
                    thumbnails.put(deviceId, result);
                    gridviewAdpt.notifyDataSetChanged();

            } else {
                //loading screen
                Log.d(TAG,"Nothing returned");
            }
        }
    }

    public Bitmap loadBitmap( String url ) {
        URL newurl = null;
        Bitmap bitmap = null;
        try {
            newurl = new URL( url );
            URLConnection uConn = newurl.openConnection();
            uConn.setUseCaches(false);
            bitmap = BitmapFactory.decodeStream(uConn.getInputStream());
        } catch ( MalformedURLException e ) {
            e.printStackTrace( );
        } catch ( IOException e ) {
            //e.printStackTrace( );
        }
        return bitmap;
    }

    public void startCall(String deviceID) {
        deviceID = "Stream-DB11-befrd47sbmh02jkoceo0";
        Log.d(TAG,"Starting activity for call operation");
        MoveClient moveClient = StreamView.getMoveClient();
        moveClient.sendAudio = false;
        moveClient.sendVideo = false;
        moveClient.receiveAudio = true;
        moveClient.receiveVideo = true;
        Intent i = new Intent(StreamView.getAppContext(), MoveCall.class);
        i.putExtra("contact", deviceID);
        i.putExtra("operation", "call");
        startActivity(i);
    }

    private void stopTimer(){
        if(thumbNailLoaderTimer1 != null){
            thumbNailLoaderTimer1.cancel();
            thumbNailLoaderTimer1.purge();
            thumbNailLoaderTimer1 = null;
            mThumbNailLoaderTt1 = null;
        }
        if(thbUrlLoaderTimer1 != null){
            thbUrlLoaderTimer1.cancel();
            thbUrlLoaderTimer1.purge();

            thbUrlLoaderTimer1 = null;
            thbUrlLoaderTt1  = null;
        }
    }

    private void startThumbnailTimer(){
        thumbNailLoaderTimer1 = new Timer();
        mThumbNailLoaderTt1 = new TimerTask() {
            public void run() {
                mThumbNailLoaderHandler.post(new Runnable() {
                    public void run(){
                        if (visiible) {
                            for (String deviceId : cameraIDs) {
                                new LoadImagefromUrl().execute(deviceId);
                            }
                        }
                        //gridviewAdpt.notifyDataSetChanged();
                    }
                });
            }
        };

        thumbNailLoaderTimer1.schedule(mThumbNailLoaderTt1, 1, 30000);
    }

    private void startURLTimer(){

        MoveClient moveClient = StreamView.getMoveClient();
        MoveRegistration curReg = moveClient.getCurrentRegistration();

        if (curReg != null) {
            for (String currentDeviceId : cameraIDs) {
                    moveClient.getCameraURL(currentDeviceId);
            }
        }

        thbUrlLoaderTimer1 = new Timer();
        thbUrlLoaderTt1 = new TimerTask() {
            public void run() {
                thbUrlLoaderHandler.post(new Runnable() {
                    public void run(){
                        MoveClient moveClient = StreamView.getMoveClient();
                        MoveRegistration curReg = moveClient.getCurrentRegistration();

                        if (curReg != null) {
                            for (String currentDeviceId : cameraIDs) {
                                    Log.d(TAG,"getting the URLs - timer");
                                    moveClient.getCameraURL(currentDeviceId);

                            }
                        }
                    }
                });
            }
        };

        thbUrlLoaderTimer1.schedule(thbUrlLoaderTt1, 1, 60*30*1000);
    }
}
