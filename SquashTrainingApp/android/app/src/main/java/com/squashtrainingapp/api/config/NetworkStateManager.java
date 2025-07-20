package com.squashtrainingapp.api.config;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkRequest;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

public class NetworkStateManager {
    private static NetworkStateManager instance;
    private ConnectivityManager connectivityManager;
    private MutableLiveData<Boolean> isNetworkAvailable = new MutableLiveData<>(false);
    private ConnectivityManager.NetworkCallback networkCallback;
    
    private NetworkStateManager(Context context) {
        connectivityManager = (ConnectivityManager) 
            context.getSystemService(Context.CONNECTIVITY_SERVICE);
        checkInitialNetworkState();
        registerNetworkCallback();
    }
    
    public static synchronized NetworkStateManager getInstance(Context context) {
        if (instance == null) {
            instance = new NetworkStateManager(context.getApplicationContext());
        }
        return instance;
    }
    
    private void checkInitialNetworkState() {
        isNetworkAvailable.postValue(isConnected());
    }
    
    private void registerNetworkCallback() {
        NetworkRequest networkRequest = new NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .addCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
            .build();
            
        networkCallback = new ConnectivityManager.NetworkCallback() {
            @Override
            public void onAvailable(Network network) {
                isNetworkAvailable.postValue(true);
            }
            
            @Override
            public void onLost(Network network) {
                // Check if we still have other networks available
                isNetworkAvailable.postValue(isConnected());
            }
            
            @Override
            public void onCapabilitiesChanged(Network network, NetworkCapabilities networkCapabilities) {
                boolean hasInternet = networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
                                    networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED);
                isNetworkAvailable.postValue(hasInternet);
            }
        };
        
        try {
            connectivityManager.registerNetworkCallback(networkRequest, networkCallback);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    public LiveData<Boolean> getNetworkState() {
        return isNetworkAvailable;
    }
    
    public boolean isConnected() {
        if (connectivityManager == null) return false;
        
        Network network = connectivityManager.getActiveNetwork();
        if (network == null) return false;
        
        NetworkCapabilities capabilities = connectivityManager.getNetworkCapabilities(network);
        return capabilities != null && 
            capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
            capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED);
    }
    
    public boolean isWifiConnected() {
        if (!isConnected()) return false;
        
        Network network = connectivityManager.getActiveNetwork();
        NetworkCapabilities capabilities = connectivityManager.getNetworkCapabilities(network);
        return capabilities != null && 
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI);
    }
    
    public boolean isCellularConnected() {
        if (!isConnected()) return false;
        
        Network network = connectivityManager.getActiveNetwork();
        NetworkCapabilities capabilities = connectivityManager.getNetworkCapabilities(network);
        return capabilities != null && 
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR);
    }
    
    public void unregisterCallback() {
        if (connectivityManager != null && networkCallback != null) {
            try {
                connectivityManager.unregisterNetworkCallback(networkCallback);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}