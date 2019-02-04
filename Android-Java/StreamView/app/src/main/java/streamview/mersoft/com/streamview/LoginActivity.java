package streamview.mersoft.com.streamview;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.TargetApi;
import android.app.LoaderManager.LoaderCallbacks;
import android.content.Context;
import android.content.CursorLoader;
import android.content.Intent;
import android.content.Loader;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.support.annotation.NonNull;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Switch;
import android.widget.TextView;

import com.mersoft.move.MoveClient;

import org.apache.commons.io.IOUtils;
import org.json.JSONObject;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import static android.Manifest.permission.READ_CONTACTS;

/**
 * A login screen that offers login via email/password.
 */
public class LoginActivity extends AppCompatActivity implements LoaderCallbacks<Cursor> {
    final static String TAG = "LoginActivity";

    /**
     * Id to identity READ_CONTACTS permission request.
     */
    private static final int REQUEST_READ_CONTACTS = 0;

    public static final String EXTRA_USER = "com.mersoft.move.USERID";
    public static final String EXTRA_TOKEN = "com.mersoft.move.TOKEN";
    public static final String EXTRA_VENDOR = "com.mersoft.move.VENDOR";

    /**
     * Keep track of the login task to ensure we can cancel it if requested.
     */
    private UserLoginTask mAuthTask = null;

    // UI references.
    private AutoCompleteTextView mEmailView;
    private EditText mPasswordView;
    private Switch mVendorView;
    private View mProgressView;
    private View mLoginFormView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        // Set up the login form.
        mEmailView = (AutoCompleteTextView) findViewById(R.id.email);
        populateAutoComplete();

        mPasswordView = (EditText) findViewById(R.id.password);
        mPasswordView.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent) {
                if (id == EditorInfo.IME_ACTION_DONE || id == EditorInfo.IME_NULL) {
                    attemptLogin();
                    return true;
                }
                return false;
            }

        });

        mVendorView = (Switch) findViewById(R.id.vendor);
        mVendorView.setOnCheckedChangeListener(new Switch.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton cb, boolean state) {
                if (state) {
                    mEmailView.setText("staging3.pepper@gmail.com");
                    mPasswordView.setText("Pepper12345");
                } else {
                    mEmailView.setText("demo1");
                    mPasswordView.setText("Mersoft1!");
                }

                return;
            }
        });

        Button mEmailSignInButton = (Button) findViewById(R.id.email_sign_in_button);
        mEmailSignInButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                attemptLogin();
            }
        });

        mLoginFormView = findViewById(R.id.login_form);
        mProgressView = findViewById(R.id.login_progress);
    }

    private void populateAutoComplete() {
        if (!mayRequestContacts()) {
            return;
        }

        getLoaderManager().initLoader(0, null, this);
    }

    private boolean mayRequestContacts() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return true;
        }
        if (checkSelfPermission(READ_CONTACTS) == PackageManager.PERMISSION_GRANTED) {
            return true;
        }
        if (shouldShowRequestPermissionRationale(READ_CONTACTS)) {
            Snackbar.make(mEmailView, R.string.permission_rationale, Snackbar.LENGTH_INDEFINITE)
                    .setAction(android.R.string.ok, new View.OnClickListener() {
                        @Override
                        @TargetApi(Build.VERSION_CODES.M)
                        public void onClick(View v) {
                            requestPermissions(new String[]{READ_CONTACTS}, REQUEST_READ_CONTACTS);
                        }
                    });
        } else {
            requestPermissions(new String[]{READ_CONTACTS}, REQUEST_READ_CONTACTS);
        }
        return false;
    }

    /**
     * Callback received when a permissions request has been completed.
     */
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        if (requestCode == REQUEST_READ_CONTACTS) {
            if (grantResults.length == 1 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                populateAutoComplete();
            }
        }
    }


    /**
     * Attempts to sign in or register the account specified by the login form.
     * If there are form errors (invalid email, missing fields, etc.), the
     * errors are presented and no actual login attempt is made.
     */
    private void attemptLogin() {
        if (mAuthTask != null) {
            return;
        }

        // Reset errors.
        mEmailView.setError(null);
        mPasswordView.setError(null);

        // Store values at the time of the login attempt.
        String email = mEmailView.getText().toString();
        String password = mPasswordView.getText().toString();
        String vendor = "mersoft";
        if (mVendorView.isChecked()) {
            vendor = "pepper";
        }

        boolean cancel = false;
        View focusView = null;

        // Check for a valid password, if the user entered one.
        if (!TextUtils.isEmpty(password) && !isPasswordValid(password)) {
            mPasswordView.setError(getString(R.string.error_invalid_password));
            focusView = mPasswordView;
            cancel = true;
        }

        // Check for a valid email address.
        if (TextUtils.isEmpty(email)) {
            mEmailView.setError(getString(R.string.error_field_required));
            focusView = mEmailView;
            cancel = true;
        } else if (!isEmailValid(email)) {
            mEmailView.setError(getString(R.string.error_invalid_email));
            focusView = mEmailView;
            cancel = true;
        }

        if (cancel) {
            // There was an error; don't attempt login and focus the first
            // form field with an error.
            focusView.requestFocus();
        } else {
            // Show a progress spinner, and kick off a background task to
            // perform the user login attempt.
            try {
                runOnUiThread(new Runnable() {

                    @Override
                    public void run() {
                        showProgress(true);
                    }
                });
                Thread.sleep(300);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }


            mAuthTask = new UserLoginTask(this, email, password, vendor);
            mAuthTask.execute((Void) null);
        }
    }

    private boolean isEmailValid(String email) {
        //TODO: Replace this with your own logic
        //return email.contains("@");
        return true;
    }

    private boolean isPasswordValid(String password) {
        //TODO: Replace this with your own logic
        //return password.length() > 4;
        return true;
    }

    /**
     * Shows the progress UI and hides the login form.
     */
    @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR2)
    private void showProgress(final boolean show) {
        // On Honeycomb MR2 we have the ViewPropertyAnimator APIs, which allow
        // for very easy animations. If available, use these APIs to fade-in
        // the progress spinner.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR2) {
            int shortAnimTime = getResources().getInteger(android.R.integer.config_shortAnimTime);

            mLoginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
            mLoginFormView.animate().setDuration(shortAnimTime).alpha(
                    show ? 0 : 1).setListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    mLoginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
                }
            });

            mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
            mProgressView.animate().setDuration(shortAnimTime).alpha(
                    show ? 1 : 0).setListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
                }
            });
        } else {
            // The ViewPropertyAnimator APIs are not available, so simply show
            // and hide the relevant UI components.
            mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
            mLoginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
        }
    }

    @Override
    public Loader<Cursor> onCreateLoader(int i, Bundle bundle) {
        return new CursorLoader(this,
                // Retrieve data rows for the device user's 'profile' contact.
                Uri.withAppendedPath(ContactsContract.Profile.CONTENT_URI,
                        ContactsContract.Contacts.Data.CONTENT_DIRECTORY), ProfileQuery.PROJECTION,

                // Select only email addresses.
                ContactsContract.Contacts.Data.MIMETYPE +
                        " = ?", new String[]{ContactsContract.CommonDataKinds.Email
                .CONTENT_ITEM_TYPE},

                // Show primary email addresses first. Note that there won't be
                // a primary email address if the user hasn't specified one.
                ContactsContract.Contacts.Data.IS_PRIMARY + " DESC");
    }

    @Override
    public void onLoadFinished(Loader<Cursor> cursorLoader, Cursor cursor) {
        List<String> emails = new ArrayList<>();
        cursor.moveToFirst();
        while (!cursor.isAfterLast()) {
            emails.add(cursor.getString(ProfileQuery.ADDRESS));
            cursor.moveToNext();
        }

        addEmailsToAutoComplete(emails);
    }

    @Override
    public void onLoaderReset(Loader<Cursor> cursorLoader) {

    }

    private void addEmailsToAutoComplete(List<String> emailAddressCollection) {
        //Create adapter to tell the AutoCompleteTextView what to show in its dropdown list.
        ArrayAdapter<String> adapter =
                new ArrayAdapter<>(LoginActivity.this,
                        android.R.layout.simple_dropdown_item_1line, emailAddressCollection);

        mEmailView.setAdapter(adapter);
    }


    private interface ProfileQuery {
        String[] PROJECTION = {
                ContactsContract.CommonDataKinds.Email.ADDRESS,
                ContactsContract.CommonDataKinds.Email.IS_PRIMARY,
        };

        int ADDRESS = 0;
        int IS_PRIMARY = 1;
    }

    /**
     * Represents an asynchronous login/registration task used to authenticate
     * the user.
     */
    public class UserLoginTask extends AsyncTask<Void, Void, Boolean> {

        private final String mEmail;
        private final String mPassword;
        private final String mVendor;
        private String mToken;
        private Context mContext;


        UserLoginTask(Context context, String email, String password, String vendor) {
            mEmail = email;
            mPassword = password;
            mContext = context;
            mVendor = vendor;
        }

        @Override
        protected Boolean doInBackground(Void... params) {
            // TODO: attempt authentication against a network service.

            //String pepperAuthURL = "https://dev.api.pepperos.io/authentication/byEmail";
            String pepperAuthURL = "https://staging.api.pepperos.io/authentication/byEmail";

            if (mVendor == "pepper") {
                String jsonResponse = null;
                try {
                    String postData = "";
                    URL myURL = new URL(pepperAuthURL);
                    HttpURLConnection myURLConnection = (HttpURLConnection)myURL.openConnection();
                    String userCredentials =  "momentum:" + mEmail + ":" + mPassword;

                    String basicAuth = "Basic " + Base64.encodeToString(userCredentials.getBytes(), Base64.NO_WRAP);
                    Log.d("PEPPERLOGIN","the auth header is "+basicAuth);
                    myURLConnection.setRequestProperty ("authorization", basicAuth);
                    myURLConnection.setRequestMethod("POST");
                    myURLConnection.setRequestProperty("Content-Type", "application/json");
                    myURLConnection.setRequestProperty("Content-Length", "" + postData.getBytes().length);
                    myURLConnection.setRequestProperty("Content-Language", "en-US");
                    myURLConnection.setUseCaches(false);
                    myURLConnection.setDoInput(true);
                    myURLConnection.setDoOutput(true);

                    int responseCode = myURLConnection.getResponseCode();
                    //String responseMsg = connection.getResponseMessage();

                    if (responseCode == 200) {
                        InputStream inputStr = myURLConnection.getInputStream();
                        String encoding = myURLConnection.getContentEncoding() == null ? "UTF-8"
                                : myURLConnection.getContentEncoding();
                        jsonResponse = IOUtils.toString(inputStr, encoding);

                        Log.d("PEPPERLOGIN","the jwt is "+jsonResponse);
                        JSONObject jwt = new JSONObject(jsonResponse);
                        JSONObject pepperUser = jwt.getJSONObject("pepperUser");

                        Log.d("PEPPERLOGIN","Account id = "+ pepperUser.getString("account_id"));
                        JSONObject cognitoProfile = jwt.getJSONObject("cognitoProfile");

                        mToken = cognitoProfile.getString("Token");
                    }

                } catch (Exception e) {
                    Log.e("PEPPERLOGIN",e.toString(), e);
                }
            } else {
                // get token and stuff for mersoft account

                //COGNETO
            }

            try {
                // Simulate network access.
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                return false;
            }

            //Get Token*******************************************************************************************

            Log.d(TAG, "Connecting move client");
            MoveClient moveClient = StreamView.getMoveClient();
            Log.d(TAG, "Registered and subscribed");


            String moveURL = "wss://move-dev.mersoft.biz/ws";
            if(!moveClient.isRegistered()) {
                if (mVendor == "pepper") {
                    moveURL = "wss://dev.move.pepperos.io/ws";
                    //moveURL = "wss://stage.move.pepperos.io/ws";
                } else {

                }
                moveClient.connect(moveURL, new MoveClient.Callback() {
                    @Override
                    public void onSuccess() {
                        Log.d(TAG, "Registering Move Client");

                        /*moveClient.register(userName, new MoveClient.Callback() {
                        //String tokenA = "eyJraWQiOiJ1cy1lYXN0LTIxIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ.eyJzdWIiOiJ1cy1lYXN0LTI6Mzk0MzBkMGYtZDFkNi00ZTYzLTljNmYtM2UzZTZiNWU5ZmY5IiwiYXVkIjoidXMtZWFzdC0yOjNkZmNjMTkzLWFhOTUtNDViMy1hNjBhLWQwYmE4YjAyMDU4MiIsImFtciI6WyJhdXRoZW50aWNhdGVkIiwiZGV2LnByb3ZpZGVyLnBlcHBlcm9zLmlvIiwiZGV2LnByb3ZpZGVyLnBlcHBlcm9zLmlvOnVzLWVhc3QtMjozZGZjYzE5My1hYTk1LTQ1YjMtYTYwYS1kMGJhOGIwMjA1ODI6OTMyYzk4MWE1NjlhNGJhN2JlNjEwMDYxMWM5OTNiZmYiXSwiaXNzIjoiaHR0cHM6Ly9jb2duaXRvLWlkZW50aXR5LmFtYXpvbmF3cy5jb20iLCJleHAiOjE1MzcyODgyNTksImlhdCI6MTUzNzI4NTI1OX0.PX_EhN5sVW3n4RtIQEQ1LjWUIj5N0t-v8c1Yu3sjhPR6CM7cccnd6iA_kBz4tR3SZgXtbR3-RDCi42yP8T5HUbCL7x3z-OqvZsL6WHw5R_5ttTgvQ07PM-j5Vjp_otu23C8XCjFLBqa0jpRsb0fBJCwzeJIrYX6Is0WteK9LfT0frw0XC3MyCERugsshQKrq88ovHB7qFAxz6FRGZxCSQqUjatusynsCH43XFTJeeft36xtEt-DKpSitAC98drp-V-U0Eo7GLza90V94qVO_sS8wQ4LU-49M7HVZlWXlPEPZz9a1tX_F3ugEFXNMmSnT31iPY1RN6YC7A-XK632DwA";
                        String tokenA   = "eyJraWQiOiJ1cy1lYXN0LTIxIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ.eyJzdWIiOiJ1cy1lYXN0LTI6Mzk0MzBkMGYtZDFkNi00ZTYzLTljNmYtM2UzZTZiNWU5ZmY5IiwiYXVkIjoidXMtZWFzdC0yOjNkZmNjMTkzLWFhOTUtNDViMy1hNjBhLWQwYmE4YjAyMDU4MiIsImFtciI6WyJhdXRoZW50aWNhdGVkIiwiZGV2LnByb3ZpZGVyLnBlcHBlcm9zLmlvIiwiZGV2LnByb3ZpZGVyLnBlcHBlcm9zLmlvOnVzLWVhc3QtMjozZGZjYzE5My1hYTk1LTQ1YjMtYTYwYS1kMGJhOGIwMjA1ODI6OTMyYzk4MWE1NjlhNGJhN2JlNjEwMDYxMWM5OTNiZmYiXSwiaXNzIjoiaHR0cHM6Ly9jb2duaXRvLWlkZW50aXR5LmFtYXpvbmF3cy5jb20iLCJleHAiOjE1MzczNjQ5NjUsImlhdCI6MTUzNzM2MTk2NX0.DRoyCXdQZkuRlV5AVEMvSfik78Rtt909K07t4wWbIj824ReV50xLGsmDArN5YGpbwhj8AvI0TWjJqTuRz9xQvH_ThXALOuGMwKWtnNu1zaYrQUyqYsED1hzea0q8LLVrszdGO2LJho2BBQMxdnv5q6mMB0YNkigmOZO2Q4kApZLDSb6CzHZ35vMKuw4Jdb6AnqJImXEEt9-slrHgiV-G9QH67I2hB0iLiccfeZfdvzieScxlkBzEF-YjTN43TfuHwhv07hANKGCneh3jDAknyoDzWiUZGbwRiO3dgiTQciirntmEFAzVnUrqD6NeaRUhsSNAbLlGHlxWMpaDmnqOrg";
                        String userNameA = "staging3.pepper@gmail.com";
                        */

                        final MoveClient moveClient = StreamView.getMoveClient();
                        moveClient.register(mEmail, mToken, mVendor, new MoveClient.Callback() {
                            @Override
                            public void onSuccess() {
                                LoginActivity.this.runOnUiThread(new Runnable() {
                                    public void run() {
                                        showProgress(false);
                                        Log.d(TAG, "Registered... ");
                                        Intent intent = new Intent(mContext, MainStreamViewActivity.class);
                                        startActivity(intent);
                                        finish();

                                        //send FB Token to move
                                        String token = MoveFireBaseService.getToken(mContext);
                                        Log.d(TAG, "Current Token is "+token);
                                        if (token != "empty") {
                                            moveClient.setToken(token);
                                        }
                                    }
                                });
                            }

                            @Override
                            public void onFailure() {
                                LoginActivity.this.runOnUiThread(new Runnable() {
                                    public void run() {
                                        showProgress(false);
                                        Log.d(TAG, "Failed to Registered... ");
                                        mPasswordView.setError("Failed to Register");
                                        mPasswordView.requestFocus();
                                    }
                                });
                            }
                        });
                    }

                    @Override
                    public void onFailure() {
                        LoginActivity.this.runOnUiThread(new Runnable() {
                            public void run() {
                                showProgress(false);
                                Log.d(TAG, "Problem connecting to Move Server");
                                mPasswordView.setError("Problem connecting to Move Server");
                                mPasswordView.requestFocus();
                            }
                        });
                    }
                });
            } else {
                //Some how we are already registered
                LoginActivity.this.runOnUiThread(new Runnable() {
                    public void run() {
                        Intent intent = new Intent(mContext, MainStreamViewActivity.class);
                        startActivity(intent);
                        finish();
                        //showProgress(false);
                    }
                });
                Log.d(TAG, "Already Registered... ");
            }

            return true;
        }

        @Override
        protected void onPostExecute(final Boolean success) {
            mAuthTask = null;

            if (success) {
                //finish();
                Log.d(TAG, "Finished Auth Task");
            } else {
                mPasswordView.setError(getString(R.string.error_incorrect_password));
                mPasswordView.requestFocus();
            }
        }

        @Override
        protected void onCancelled() {
            mAuthTask = null;
            showProgress(false);
        }
    }
}

