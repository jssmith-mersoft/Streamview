package streamview.mersoft.com.streamview;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.mersoft.move.MoveClient;

public class Account extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_account);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);

        //Set the Contents
        MoveClient moveClient = StreamView.getMoveClient();
        LinearLayout viewContents = (LinearLayout) findViewById(R.id.viewContent);

        LinearLayout a = new LinearLayout(this);
        a.setOrientation(LinearLayout.HORIZONTAL);
        // Create TextView programmatically.
        TextView textLabel = new TextView(this);
        //textLabel.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        //textLabel.setGravity(Gravity.LEFT);
        textLabel.setText(R.string.account_name);
        a.addView(textLabel);

        if (moveClient.getCurrentRegistration() != null) {
            textLabel = new TextView(this);
            //textLabel.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            //textLabel.setGravity(Gravity.LEFT);
            textLabel.setText(moveClient.getCurrentRegistration().getName());
            a.addView(textLabel);
            viewContents.addView(a);
        }

/*
        // Create TextView programmatically.
        TextView textView = new TextView(this);
        textView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        textView.setGravity(Gravity.LEFT);
        textView.setText(R.string.account_name);
        textView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(MainActivity.this, R.string.clicked_on_me, Toast.LENGTH_LONG).show();
            }
        });
*/

        Button btnSignOut = new Button(this);
        btnSignOut.setText(R.string.account_logout);

        btnSignOut.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                moveClient.unRegister();
                if (moveClient.isRegistered() == false) {
                    Toast.makeText(Account.this, R.string.account_logout, Toast.LENGTH_LONG).show();
                }
                Intent e=new Intent(Account.this,LoginActivity.class);
                startActivity(e);
                finish();
            }
        });

        viewContents.addView(btnSignOut);


    }

    @Override
    public void onBackPressed() {
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
            Intent h=new Intent(Account.this,Account.class);
            startActivity(h);
        } else if (id == R.id.nav_events) {
            Intent e=new Intent(Account.this,Events.class);
            startActivity(e);
        } else if (id == R.id.nav_home) {
            Intent e=new Intent(Account.this,MainStreamViewActivity.class);
            startActivity(e);
        } else if (id == R.id.nav_provisionQR) {
            Intent e=new Intent(Account.this,ProvisionSoftQR.class);
            startActivity(e);
        } else if (id == R.id.nav_provisionSAP) {
            Intent e=new Intent(Account.this,ProvisionSoftAP.class);
            startActivity(e);
        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }
}
