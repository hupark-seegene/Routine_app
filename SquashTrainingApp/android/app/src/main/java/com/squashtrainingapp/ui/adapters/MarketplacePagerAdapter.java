package com.squashtrainingapp.ui.adapters;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import com.squashtrainingapp.ui.fragments.MarketplaceBrowseFragment;
import com.squashtrainingapp.ui.fragments.MyContentFragment;
import com.squashtrainingapp.ui.fragments.MyLibraryFragment;

public class MarketplacePagerAdapter extends FragmentStateAdapter {
    
    public MarketplacePagerAdapter(@NonNull FragmentActivity fragmentActivity) {
        super(fragmentActivity);
    }
    
    @NonNull
    @Override
    public Fragment createFragment(int position) {
        switch (position) {
            case 0:
                return new MarketplaceBrowseFragment();
            case 1:
                return new MyLibraryFragment();
            case 2:
                return new MyContentFragment();
            default:
                return new MarketplaceBrowseFragment();
        }
    }
    
    @Override
    public int getItemCount() {
        return 3;
    }
}