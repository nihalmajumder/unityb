public with sharing class CommunityFollowController {

	public EntitySubscription subscription { get;set; }
	public Id subscriptionParentId {
		get;
		set {
			if (subscriptionParentId == NULL) {
				subscriptionParentId = value;
				List<EntitySubscription> subscriptionForEventList = [SELECT Id FROM EntitySubscription 
					WHERE ParentId = :this.subscriptionParentId 
					AND SubscriberId = :UserInfo.getUserId() 
					LIMIT 1
				];
				subscription = (subscriptionForEventList.size() == 0) ? new EntitySubscription() : subscriptionForEventList[0];
			}
		}
	}

	public PageReference follow() {
		if (subscription.Id != NULL) {
			delete subscription;
			subscription = new EntitySubscription();
		}
		else {
			subscription.ParentId = this.subscriptionParentId;
			subscription.SubscriberId = UserInfo.getUserId();
			if (Network.getNetworkId() != NULL) {
				subscription.put('NetworkId', Network.getNetworkId());
			}
			insert subscription;
		}
		return NULL;
	}

	public Boolean followed {
		get {
			return subscription.Id != NULL;
		}
	}
}