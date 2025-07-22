package com.squashtrainingapp.ui.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.squashtrainingapp.R;

public class EmptyFragment extends Fragment {
    
    private static final String ARG_TEXT = "text";
    
    public static EmptyFragment newInstance(String text) {
        EmptyFragment fragment = new EmptyFragment();
        Bundle args = new Bundle();
        args.putString(ARG_TEXT, text);
        fragment.setArguments(args);
        return fragment;
    }
    
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_empty, container, false);
        
        TextView textView = view.findViewById(R.id.empty_text);
        if (getArguments() != null) {
            textView.setText(getArguments().getString(ARG_TEXT, ""));
        }
        
        return view;
    }
}