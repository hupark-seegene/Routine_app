package com.squashtrainingapp.ui.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.fragment.app.Fragment;

import com.squashtrainingapp.R;

public class MarketplaceBrowseFragment extends Fragment {
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // This fragment is handled by the parent activity
        // Just return an empty view
        View view = new View(getContext());
        view.setVisibility(View.GONE);
        return view;
    }
}