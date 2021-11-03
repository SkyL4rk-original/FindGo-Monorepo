final mockUser = {
  "userUuid": "12345",
  "email": "d@e.com",
  "firstName": "David",
  "lastName": "Gericke",
  "status": "1",
  "createdAt": "2021-01-01",
  "updatedAt": "2021-01-01",
};

final mockSpecial = {
  "specialUuid": "1",
  "storeUuid": "1",
  "storeImageUrl": "https://skylarktraining.co.za/specials/php/store-images/lapiazza-logo.jpg",
  "storeCategory": "Restaurant",
  "storeName": "La Piazza",
  "name": "Pizza Special",
  "price": 9000,
  "validFrom": "2021-05-28",
  "validUntil": "2021-05-29",
  "description": "Sed ullamcorper neque quam, sit amet viverra neque pulvinar pulvinar. Suspendisse ut dictum mauris, fermentum porttitor elit. Aenean rhoncus nulla quis massa rhoncus, nec dapibus leo sodales.",
  "imageUrl": "https://skylarktraining.co.za/specials/php/images/lapiazza.jpg",
  "videoUrl": "",
  "type": "brand",
  "status": "inactive",
};

final mockSpecial2 = {
  "specialUuid": "2",
  "storeUuid": "2",
  "storeImageUrl": "https://skylarktraining.co.za/specials/php/store-images/nandos-logo.jpg",
  "storeCategory": "Restaurant",
  "storeName": "Nandos",
  "name": "Chicken",
  "price": 12000,
  "validFrom": "2021-05-28",
  "validUntil": "2021-05-29",
  "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis accumsan, erat in molestie semper, mi sem facilisis elit, nec imperdiet metus dolor vitae dolor. Sed ullamcorper neque quam, sit amet viverra neque pulvinar pulvinar.",
  "imageUrl": "http://skylarktraining.co.za/specials/php/images/nandos-special.jpg",
  "videoUrl": "",
  "type": "brand",
  "status": "active",
};

final mockSpecial3 = {
  "specialUuid": "3",
  "storeUuid": "1",
  "storeImageUrl": "https://skylarktraining.co.za/specials/php/store-images/lapiazza-logo.jpg",
  "storeCategory": "Restaurant",
  "storeName": "La Piazza",
  "name": "Feel Good Friday",
  "price": 12000,
  "validFrom": "2021-06-10",
  "validUntil": "2021-06-10",
  "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis accumsan, erat in molestie semper, mi sem facilisis elit, nec imperdiet metus dolor vitae dolor. Sed ullamcorper neque quam, sit amet viverra neque pulvinar pulvinar.",
  "imageUrl": "http://skylarktraining.co.za/specials/php/images/lapiazza-event.jpg",
  "videoUrl": "",
  "type": "event",
  "status": "repeated",
};

final mockSpecialsList = [mockSpecial2, mockSpecial, mockSpecial3];


final mockStore = {
  "storeUuid": "1",
  "imageUrl": "https://skylarktraining.co.za/specials/php/store-images/lapiazza-logo.jpg",
  "category": "Restaurant",
  "name": "La Piazza",
  "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis accumsan, erat in molestie semper, mi sem facilisis elit, nec imperdiet metus dolor vitae dolor."
};

final mockStore2 = {
  "storeUuid": "2",
  "imageUrl": "http://skylarktraining.co.za/specials/php/store-images/nandos-logo.jpg",
  "category": "Restaurant",
  "name": "Nandos",
  "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis accumsan, erat in molestie semper, mi sem facilisis elit, nec imperdiet metus dolor vitae dolor."
};

final mockStore3 = {
  "storeUuid": "3",
  "imageUrl": "http://skylarktraining.co.za/specials/php/store-images/nandos-logo.jpg",
  "category": "Restaurant",
  "name": "Burger King",
  "description": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis accumsan, erat in molestie semper, mi sem facilisis elit, nec imperdiet metus dolor vitae dolor."
};

final mockStoreList = [mockStore, mockStore2, mockStore3];

final mockFollowedStoreUuidList = ["1"];