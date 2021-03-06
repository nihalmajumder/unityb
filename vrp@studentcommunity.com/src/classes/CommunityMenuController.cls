public with sharing class CommunityMenuController {

	private static Boolean currentPage(String urlToCompare) {
		String currentPageName = ApexPages.currentPage().getUrl().replace('/apex','');
		urlToCompare = urlToCompare.replace('/apex','');
		String pp = CommunityUtils.getPackagePrefix();
		if (String.isNotBlank(pp)) {
			urlToCompare = urlToCompare.replace(pp, '');
			currentPageName = currentPageName.replace(pp, '');
		}
		return currentPageName.containsIgnoreCase(urlToCompare);
	}

	public static String getRegistration() {
		String result = 'false';
		if (!currentPage(Page.CommunityRegTerms.getUrl()) && !currentPage(Page.Community404.getUrl())) {
			CommunityRegTermsController crtc = new CommunityRegTermsController();
			result = crtc.checkAndPrepareMenu();
		}
		return result;
	}

	public static Boolean getIsRegTermsPage() {
		return currentPage(Page.CommunityRegTerms.getUrl());
	}

	public PageReference getRedirectToLogin() {
		PageReference pr;
		if (UserInfo.getUserType() == 'Guest') {
			pr = Network.forwardToAuthPage(NULL);
			
		}
		return pr;
	}

	public String getAlert() {
		DateTime Now = DateTime.now();
		List<Community_News__c> newsList = [
			SELECT Id, Name, Teaser__c
			FROM Community_News__c
			WHERE Alert__c = true AND Status__c != 'Pending'
			AND Entry_Date__c <= :Now AND Expiration_Date__c >= :Now
			LIMIT 1
		];
		return newsList.isEmpty() ? '' : newsList[0].Teaser__c;
	}

	public String getHelpLink() {
		List<Community_Resource__c> helpList = [SELECT Id, Link__c FROM Community_Resource__c WHERE Status__c = 'Active' AND Help_Link__c = true AND Link__c != NULL];
		return (helpList.size() > 0 && String.isNotBlank(helpList[0].Link__c)) ? helpList[0].Link__c : NULL;
	}

	// -- variables -- lists for wrapper class --
	public static List<LinkItem> LinkItems {
		get {
			List<LinkItem> temp = new List<LinkItem>();

			List<Community_Resource__c>  tmp = [
				SELECT Name, Link__c, Sort__c
				FROM Community_Resource__c 
				WHERE Quick_Link__c = TRUE AND Link__c != NULL AND Status__c = 'Active'
				ORDER BY Sort__c, Name
			];
			// As each CommunityResource__c is processed we create a new LinkItem object and add it to the LinkItems
			for (Community_Resource__c cr : tmp) {
				temp.add(new LinkItem(cr.Name, cr.Link__c));
			}

			return temp;
		}
	}
	
	// -- Wrapper class --
	public class LinkItem {
		public String Name {get; set;}
		public String Link {get; set;}

		public LinkItem(String Name, String Link) {
			this.Name = Name;
			this.Link = Link;
		} 
	}
}