package com.squashtrainingapp.ui.adapters;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import com.squashtrainingapp.ui.fragments.EmptyFragment;

public class LeaderboardPagerAdapter extends FragmentStateAdapter {
    
    private final int tabCount;
    
    public LeaderboardPagerAdapter(@NonNull FragmentActivity fragmentActivity, int tabCount) {
        super(fragmentActivity);
        this.tabCount = tabCount;
    }
    
    @NonNull
    @Override
    public Fragment createFragment(int position) {
        // Using empty fragments for now as we're using RecyclerView directly
        return EmptyFragment.newInstance("Tab " + position);
    }
    
    @Override
    public int getItemCount() {
        return tabCount;
    }
}