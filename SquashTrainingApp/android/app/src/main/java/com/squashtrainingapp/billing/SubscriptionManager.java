package com.squashtrainingapp.billing;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.android.billingclient.api.AcknowledgePurchaseParams;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.ProductDetails;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.android.billingclient.api.QueryProductDetailsParams;
import com.android.billingclient.api.QueryPurchasesParams;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;
import com.squashtrainingapp.auth.FirebaseAuthManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SubscriptionManager implements PurchasesUpdatedListener {
    private static final String TAG = "SubscriptionManager";
    
    // Product IDs (must match Google Play Console)
    public static final String MONTHLY_SUBSCRIPTION_ID = "squash_premium_monthly";
    public static final String YEARLY_SUBSCRIPTION_ID = "squash_premium_yearly";
    
    private static SubscriptionManager instance;
    private BillingClient billingClient;
    private Context context;
    private List<ProductDetails> productDetailsList = new ArrayList<>();
    private SubscriptionListener subscriptionListener;
    
    // Pricing (will be fetched from Play Store)
    private String monthlyPrice = "$9.99";
    private String yearlyPrice = "$79.99";
    
    public interface SubscriptionListener {
        void onSubscriptionStatusChanged(boolean isPremium);
        void onPurchaseSuccess(String productId);
        void onPurchaseError(String error);
        void onProductsLoaded(List<ProductDetails> products);
    }
    
    private SubscriptionManager(Context context) {
        this.context = context.getApplicationContext();
        initializeBillingClient();
    }
    
    public static synchronized SubscriptionManager getInstance(Context context) {
        if (instance == null) {
            instance = new SubscriptionManager(context);
        }
        return instance;
    }
    
    public void setSubscriptionListener(SubscriptionListener listener) {
        this.subscriptionListener = listener;
    }
    
    private void initializeBillingClient() {
        billingClient = BillingClient.newBuilder(context)
                .setListener(this)
                .enablePendingPurchases()
                .build();
        
        connectToBillingService();
    }
    
    private void connectToBillingService() {
        billingClient.startConnection(new BillingClientStateListener() {
            @Override
            public void onBillingSetupFinished(@NonNull BillingResult billingResult) {
                if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                    Log.d(TAG, "Billing service connected");
                    queryProducts();
                    checkExistingPurchases();
                }
            }
            
            @Override
            public void onBillingServiceDisconnected() {
                Log.d(TAG, "Billing service disconnected");
                // Try to reconnect
                connectToBillingService();
            }
        });
    }
    
    private void queryProducts() {
        List<QueryProductDetailsParams.Product> productList = new ArrayList<>();
        
        productList.add(
                QueryProductDetailsParams.Product.newBuilder()
                        .setProductId(MONTHLY_SUBSCRIPTION_ID)
                        .setProductType(BillingClient.ProductType.SUBS)
                        .build()
        );
        
        productList.add(
                QueryProductDetailsParams.Product.newBuilder()
                        .setProductId(YEARLY_SUBSCRIPTION_ID)
                        .setProductType(BillingClient.ProductType.SUBS)
                        .build()
        );
        
        QueryProductDetailsParams params = QueryProductDetailsParams.newBuilder()
                .setProductList(productList)
                .build();
        
        billingClient.queryProductDetailsAsync(params,
                (billingResult, productDetailsList) -> {
                    if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                        this.productDetailsList = productDetailsList;
                        
                        // Extract prices
                        for (ProductDetails productDetails : productDetailsList) {
                            if (productDetails.getProductId().equals(MONTHLY_SUBSCRIPTION_ID)) {
                                ProductDetails.SubscriptionOfferDetails offerDetails = 
                                        productDetails.getSubscriptionOfferDetails().get(0);
                                monthlyPrice = offerDetails.getPricingPhases()
                                        .getPricingPhaseList().get(0).getFormattedPrice();
                            } else if (productDetails.getProductId().equals(YEARLY_SUBSCRIPTION_ID)) {
                                ProductDetails.SubscriptionOfferDetails offerDetails = 
                                        productDetails.getSubscriptionOfferDetails().get(0);
                                yearlyPrice = offerDetails.getPricingPhases()
                                        .getPricingPhaseList().get(0).getFormattedPrice();
                            }
                        }
                        
                        if (subscriptionListener != null) {
                            subscriptionListener.onProductsLoaded(productDetailsList);
                        }
                    }
                });
    }
    
    // Launch subscription purchase flow
    public void purchaseSubscription(Activity activity, String productId) {
        ProductDetails productDetails = null;
        
        for (ProductDetails details : productDetailsList) {
            if (details.getProductId().equals(productId)) {
                productDetails = details;
                break;
            }
        }
        
        if (productDetails == null) {
            if (subscriptionListener != null) {
                subscriptionListener.onPurchaseError("Product not found");
            }
            return;
        }
        
        List<BillingFlowParams.ProductDetailsParams> productDetailsParamsList = 
                new ArrayList<>();
        
        BillingFlowParams.ProductDetailsParams productDetailsParams = 
                BillingFlowParams.ProductDetailsParams.newBuilder()
                        .setProductDetails(productDetails)
                        .setOfferToken(productDetails.getSubscriptionOfferDetails().get(0).getOfferToken())
                        .build();
        
        productDetailsParamsList.add(productDetailsParams);
        
        BillingFlowParams billingFlowParams = BillingFlowParams.newBuilder()
                .setProductDetailsParamsList(productDetailsParamsList)
                .build();
        
        BillingResult billingResult = billingClient.launchBillingFlow(activity, billingFlowParams);
        
        if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            if (subscriptionListener != null) {
                subscriptionListener.onPurchaseError("Failed to launch purchase flow");
            }
        }
    }
    
    @Override
    public void onPurchasesUpdated(@NonNull BillingResult billingResult, 
                                   @Nullable List<Purchase> purchases) {
        if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK 
                && purchases != null) {
            for (Purchase purchase : purchases) {
                handlePurchase(purchase);
            }
        } else if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.USER_CANCELED) {
            if (subscriptionListener != null) {
                subscriptionListener.onPurchaseError("Purchase cancelled");
            }
        } else {
            if (subscriptionListener != null) {
                subscriptionListener.onPurchaseError("Purchase failed: " + billingResult.getDebugMessage());
            }
        }
    }
    
    private void handlePurchase(Purchase purchase) {
        // Verify purchase
        if (purchase.getPurchaseState() == Purchase.PurchaseState.PURCHASED) {
            // Acknowledge purchase
            if (!purchase.isAcknowledged()) {
                AcknowledgePurchaseParams acknowledgePurchaseParams =
                        AcknowledgePurchaseParams.newBuilder()
                                .setPurchaseToken(purchase.getPurchaseToken())
                                .build();
                
                billingClient.acknowledgePurchase(acknowledgePurchaseParams, billingResult -> {
                    if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                        // Update user subscription status
                        updateUserSubscription(purchase);
                    }
                });
            } else {
                updateUserSubscription(purchase);
            }
        }
    }
    
    private void updateUserSubscription(Purchase purchase) {
        String userId = FirebaseAuth.getInstance().getCurrentUser().getUid();
        
        // Update Firebase
        FirebaseAuthManager.getInstance(context).updateSubscriptionStatus(
                userId, FirebaseAuthManager.SubscriptionStatus.PREMIUM
        );
        
        // Save purchase details
        Map<String, Object> purchaseData = new HashMap<>();
        purchaseData.put("productId", purchase.getProducts().get(0));
        purchaseData.put("purchaseToken", purchase.getPurchaseToken());
        purchaseData.put("purchaseTime", purchase.getPurchaseTime());
        purchaseData.put("orderId", purchase.getOrderId());
        purchaseData.put("isAutoRenewing", purchase.isAutoRenewing());
        
        FirebaseFirestore.getInstance()
                .collection("purchases")
                .document(userId)
                .set(purchaseData)
                .addOnSuccessListener(aVoid -> {
                    if (subscriptionListener != null) {
                        subscriptionListener.onPurchaseSuccess(purchase.getProducts().get(0));
                        subscriptionListener.onSubscriptionStatusChanged(true);
                    }
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Failed to save purchase", e);
                });
    }
    
    // Check if user has active subscription
    public void checkExistingPurchases() {
        billingClient.queryPurchasesAsync(
                QueryPurchasesParams.newBuilder()
                        .setProductType(BillingClient.ProductType.SUBS)
                        .build(),
                (billingResult, purchases) -> {
                    if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                        boolean hasActiveSubscription = false;
                        
                        for (Purchase purchase : purchases) {
                            if (purchase.getPurchaseState() == Purchase.PurchaseState.PURCHASED) {
                                hasActiveSubscription = true;
                                // Make sure it's acknowledged
                                if (!purchase.isAcknowledged()) {
                                    handlePurchase(purchase);
                                }
                            }
                        }
                        
                        if (subscriptionListener != null) {
                            subscriptionListener.onSubscriptionStatusChanged(hasActiveSubscription);
                        }
                        
                        // Update Firebase if no active subscription
                        if (!hasActiveSubscription && FirebaseAuth.getInstance().getCurrentUser() != null) {
                            String userId = FirebaseAuth.getInstance().getCurrentUser().getUid();
                            FirebaseAuthManager.getInstance(context).updateSubscriptionStatus(
                                    userId, FirebaseAuthManager.SubscriptionStatus.FREE
                            );
                        }
                    }
                });
    }
    
    // Restore purchases
    public void restorePurchases() {
        checkExistingPurchases();
    }
    
    // Get pricing
    public String getMonthlyPrice() {
        return monthlyPrice;
    }
    
    public String getYearlyPrice() {
        return yearlyPrice;
    }
    
    public String getYearlySavings() {
        // Calculate savings percentage
        try {
            double monthly = Double.parseDouble(monthlyPrice.replaceAll("[^0-9.]", ""));
            double yearly = Double.parseDouble(yearlyPrice.replaceAll("[^0-9.]", ""));
            double yearlyEquivalent = monthly * 12;
            double savings = ((yearlyEquivalent - yearly) / yearlyEquivalent) * 100;
            return String.format("%.0f%%", savings);
        } catch (Exception e) {
            return "33%"; // Default savings
        }
    }
}