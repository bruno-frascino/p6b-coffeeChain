App = {
    web3Provider: null,
    contracts: {},
    emptyAddress: "0x0000000000000000000000000000000000000000",
    sku: 0,
    upc: 0,
    metamaskAccountID: "0x0000000000000000000000000000000000000000",
    ownerID: "0x0000000000000000000000000000000000000000",
    originGrowerID: "0x0000000000000000000000000000000000000000",
    originGrowerName: null,
    originGrowerInformation: null,
    originGrowerLatitude: null,
    originGrowerLongitude: null,
    productNotes: null,
    productPrice: 0,
    intermediaryID: "0x0000000000000000000000000000000000000000",
    roasterID: "0x0000000000000000000000000000000000000000",
    retailerID: "0x0000000000000000000000000000000000000000",
    consumerID: "0x0000000000000000000000000000000000000000",

    init: async function () {
        App.readForm();
        /// Setup access to blockchain
        return await App.initWeb3();
    },

    readForm: function () {
        App.sku = $("#sku").val();
        App.upc = $("#upc").val();
        App.ownerID = $("#ownerID").val();
        App.originGrowerID = $("#originGrowerID").val();
        App.originGrowerName = $("#originGrowerName").val();
        App.originGrowerInformation = $("#originGrowerInformation").val();
        App.originGrowerLatitude = $("#originGrowerLatitude").val();
        App.originGrowerLongitude = $("#originGrowerLongitude").val();
        App.productNotes = $("#productNotes").val();
        App.productPrice = $("#productPrice").val();
        App.intermediaryID = $("#intermediaryID").val();
        App.roasterID = $("#roasterID").val();
        App.retailerID = $("#retailerID").val();
        App.consumerID = $("#consumerID").val();

        console.log(
            App.sku,
            App.upc,
            App.ownerID, 
            App.originGrowerID, 
            App.originGrowerName, 
            App.originGrowerInformation, 
            App.originGrowerLatitude, 
            App.originGrowerLongitude, 
            App.productNotes, 
            App.productPrice, 
            App.intermediaryID, 
            App.roasterID,
            App.retailerID, 
            App.consumerID
        );
    },

    initWeb3: async function () {
        /// Find or Inject Web3 Provider
        /// Modern dapp browsers...
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            try {
                // Request account access
                await window.ethereum.enable();
            } catch (error) {
                // User denied account access...
                console.error("User denied account access")
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        }
        // If no injected web3 instance is detected, fall back to Ganache
        else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        }

        App.getMetaskAccountID();

        return App.initSupplyChain();
    },

    getMetaskAccountID: function () {
        web3 = new Web3(App.web3Provider);

        // Retrieving accounts
        web3.eth.getAccounts(function(err, res) {
            if (err) {
                console.log('Error:',err);
                return;
            }
            App.metamaskAccountID = res[0];
            console.log('getMetaskAccountID:',res[0]);
        })
    },

    initSupplyChain: function () {
        // Source the truffle compiled smart contracts
        var jsonSupplyChain='../../build/contracts/SupplyChain.json';
        
        // JSONfy the smart contracts
        $.getJSON(jsonSupplyChain, function(data) {
            console.log('data',data);
            var SupplyChainArtifact = data;
            App.contracts.SupplyChain = TruffleContract(SupplyChainArtifact);
            App.contracts.SupplyChain.setProvider(App.web3Provider);
            
            App.fetchItemBufferOne();
            App.fetchItemBufferTwo();
            App.fetchEvents();

        });

        return App.bindEvents();
    },

    bindEvents: function() {
        $(document).on('click', App.handleButtonClick);
    },

    handleButtonClick: async function(event) {
        event.preventDefault();

        App.getMetaskAccountID();

        var processId = parseInt($(event.target).data('id'));
        console.log('processId',processId);

        switch(processId) {
            case 1:
                return await App.harvestItem(event);
                break;
            case 2:
                return await App.hullItem(event);
                break;
            case 3:
                return await App.dryItem(event);
                break;
            case 4:
                return await App.cropPackItem(event);
                break;
            case 5:
                return await App.sellCropItem(event);
                break;
            case 6:
                return await App.buyCropItem(event);
                break;
            case 7:
                return await App.sellInterItem(event);
                break;
            case 8:
                return await App.buyInterItem(event);
                break;
            case 9:
                return await App.roast(event);
                break;
            case 10:
                return await App.roastPack(event);
                break;
            case 11:
                return await App.sellRoastItem(event);
                break;
            case 12:
                return await App.buyRoastItem(event);
                break;
            case 13:
                return await App.sellItem(event);
                break;
            case 14:
                return await App.purchaseItem(event);
                break;
            case 15:
                return await App.fetchItemBufferOne(event);
                break;
            case 16:
                return await App.fetchItemBufferTwo(event);
                break;
            }
    },

    harvestItem: function(event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.readForm();

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.harvestItem(
                App.upc, 
                App.metamaskAccountID, 
                App.originGrowerName, 
                App.originGrowerInformation, 
                App.originGrowerLatitude, 
                App.originGrowerLongitude, 
                App.productNotes
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('harvestItem',result);

            App.originGrowerID = App.metamaskAccountID;
            $("#originGrowerID").val(App.originGrowerID);
            $("#it-state").html("Item state: <b>Harvested</b>");
            console.log('Item state: ' + result[5]);

        }).catch(function(err) {
            console.log(err.message);
        });
    },

    hullItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.hullItem(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('hullItem',result);
            $("#it-state").html("Item state: <b>Hulled</b>");
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    dryItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.dryItem(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('dryItem',result);
            $("#it-state").html("Item state: <b>Dried</b>");
        }).catch(function(err) {
            console.log(err.message);
        });
    },
    
    cropPackItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.cropPackItem(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('cropPackItem',result);
            $("#it-state").html("Item state: <b>CropPacked</b>");
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    sellCropItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const productPrice = web3.toWei(1, "ether");
            console.log('productPrice',productPrice);
            return instance.sellCropItem(App.upc, App.productPrice, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('sellCropItem',result);
            $("#it-state").html("Item state: <b>CropForSale</b>");
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    buyCropItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const walletValue = web3.toWei(3, "ether");
            return instance.buyCropItem(App.upc, {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('buyCropItem',result);

            App.fetchItemBufferTwo(App.upc);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    sellInterItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const productPrice = web3.toWei(1.3, "ether");
            console.log('productPrice',productPrice);
            return instance.sellInterItem(App.upc, App.productPrice, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('sellInterItem',result);

            $("#it-state").html("Item state: <b>InterForSale</b>");
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    buyInterItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const walletValue = web3.toWei(3, "ether");
            return instance.buyInterItem(App.upc, {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('buyInterItem',result);

            App.fetchItemBufferTwo(App.upc);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    roast: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.roast(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('roast',result);

            $("#it-state").html("Item state: <b>Roasted</b>");
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    roastPack: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.roastPack(App.upc, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('roastPack',result);

            $("#it-state").html("Item state: <b>RoastPacked</b>");
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    sellRoastItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const productPrice = web3.toWei(1.6, "ether");
            console.log('productPrice',productPrice);
            return instance.sellRoastItem(App.upc, App.productPrice, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('sellRoastItem',result);

            $("#it-state").html("Item state: <b>RoastForSale</b>");
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    buyRoastItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const walletValue = web3.toWei(3, "ether");
            return instance.buyRoastItem(App.upc, {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('buyRoastItem',result);

            App.fetchItemBufferTwo(App.upc);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    sellItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const productPrice = web3.toWei(1.9, "ether");
            console.log('productPrice',productPrice);
            return instance.sellItem(App.upc, App.productPrice, {from: App.metamaskAccountID});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('sellItem',result);

            $("#it-state").html("Item state: <b>ForSale</b>");
        }).catch(function(err) {
            console.log(err.message);
        });
    },


    purchaseItem: function (event) {
        event.preventDefault();
        var processId = parseInt($(event.target).data('id'));

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const walletValue = web3.toWei(3, "ether");
            return instance.purchaseItem(App.upc, {from: App.metamaskAccountID, value: walletValue});
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('purchaseItem',result);

            App.fetchItemBufferTwo(App.upc);
        }).catch(function(err) {
            console.log(err.message);
        });
    },


    fetchItemBufferOne: function () {
    ///   event.preventDefault();
    ///    var processId = parseInt($(event.target).data('id'));
        App.upc = $('#upc').val();
        console.log('upc',App.upc);

        App.contracts.SupplyChain.deployed().then(function(instance) {
          return instance.fetchItemBufferOne(App.upc);
        }).then(function(result) {
          $("#ftc-item").text(result);
          console.log('fetchItemBufferOne', result);
        
          //ownerID
          $("#ownerID").val(result[2]);
          //originGrowerID
          $("#originGrowerID").val(result[3]);
          //originGrowerName
          $("#originGrowerName").val(result[4]);
          //originGrowerInformation
          $("#originGrowerInformation").val(result[5]);
          //originGrowerLatitude
          $("#originGrowerLatitude").val(result[6]);
          //originGrowerLongitude
          $("#originGrowerLongitude").val(result[7]);

        }).catch(function(err) {
          console.log(err.message);
        });
    },

    fetchItemBufferTwo: function () {
    ///    event.preventDefault();
    ///    var processId = parseInt($(event.target).data('id'));
                        
        App.contracts.SupplyChain.deployed().then(function(instance) {
          return instance.fetchItemBufferTwo.call(App.upc);
        }).then(function(result) {
          $("#ftc-item").text(result);
          console.log('fetchItemBufferTwo', result);

          //productID
          //$("#productID").val(result[2]);
          console.log('Product Id: ' + result[2]);
          
        //productNotes
        $("#productNotes").val(result[3]);
        //only update price field when is for consumer purchase
        if( App.retailerID != '0x0000000000000000000000000000000000000000'){
          //productPrice
          $("#productPrice").val(result[4]);
        }
          //itemState
          let itState = '';
          let r = '' + result[5];
          switch( r ) {
            case '0':
                itState = "Harvested";
                break;
            case '1':
                itState = "Hulled";
                break;
            case '2':
                itState = "Dried";
                break;
            case '3':
                itState = "CropPacked";
                break;
            case '4':
                itState = "CropForSale";
                break;
            case '5':
                itState = "InterItem";
                break;
            case '6':
                itState = "InterForSale";
                break;
            case '7':
                itState = "RoastItem";
                break;
            case '8':
                itState = "Roasted";
                break;
            case '9':
                itState = "RoastPacked";
                break;
            case '10':
                itState = "RoastForSale";
                break;
            case '11':
                itState = "RetailerItem";
                break;
            case '12':
                itState = "ForSale";
                break;
            case '13':
                itState = "Purchased";
                break;
          }
          //only after first interaction
          if( App.originGrowerID != '0x0000000000000000000000000000000000000000' ){
            $("#it-state").html("Item state: <b>"+ itState +"</b>");
            console.log('Item state: ' + result[5]);
          }
          //intermediaryID
          $("#intermediaryID").val(result[6]);
          //roasterID
          $("#roasterID").val(result[7]);
          //retailerID
          $("#retailerID").val(result[8]);
          //consumerID
          $("#consumerID").val(result[9]);
        

        }).catch(function(err) {
          console.log(err.message);
        });
    },

    fetchEvents: function () {
        if (typeof App.contracts.SupplyChain.currentProvider.sendAsync !== "function") {
            App.contracts.SupplyChain.currentProvider.sendAsync = function () {
                return App.contracts.SupplyChain.currentProvider.send.apply(
                App.contracts.SupplyChain.currentProvider,
                    arguments
              );
            };
        }

        App.contracts.SupplyChain.deployed().then(function(instance) {
        var events = instance.allEvents(function(err, log){
          if (!err)
            $("#ftc-events").append('<li>' + log.event + ' - ' + log.transactionHash + '</li>');
        });
        }).catch(function(err) {
          console.log(err.message);
        });
        
    }
};

$(function () {
    $(window).load(function () {
        App.init();
    });
});
