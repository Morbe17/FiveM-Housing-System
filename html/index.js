var inventoryItems = []
var bankItems = []
var propertyId
var propertyMaxCapacity
var actualCapacity

$(function () {
    function display(bool) {
        if (bool) {
            $("#container").show();
        } else {
            $("#container").hide();
        }
    }

    function displayInventory(bool) {
        if (bool) {
            $(".box").show();
        }else{
            $(".box").hide();
        }
    }

    display(false)
    displayInventory(false)

    var displayType
    var property

    window.addEventListener('message', function(event) {
        var item = event.data;
        displayType = item.invType
        property = item.prop
        if (item.type === "propertyName") {
            if (item.status == true) {
                display(true)
        
            } else {
                display(false)
            }
        } else if(item.type === "propertyInventory") {
            if (item.status == true) {
                displayInventory(true)
            } else {
                displayInventory(false)
            }
        } else if (item.type === "sendInventory") {
            inventoryItems = item.plInventory
            bankItems = item.prInventory
            propertyId = item.propertyId
            propertyMaxCapacity = item.storageValues.propertyMaxCapacity
            actualCapacity = item.storageValues.actualCapacity

            document.getElementById('maxQ').innerHTML  = '['+ actualCapacity + '/' + propertyMaxCapacity + ']'


            refreshItems();
        }
    })



    // if the person uses the escape key, it will exit the resource
    document.onkeyup = function (data) {
        if (data.which == 27) {
            $.post('https://properties/exit', JSON.stringify({}));
            return
        } else if (data.which == 114) { 
            $.post('https://properties/exit', JSON.stringify({}));
            return
        }
    };

    $("#button2").click(function () {
        $.post('https://properties/exit', JSON.stringify({}));
        return
    })

    $("#button1").click(function () {
        var name = document.getElementById("propName").value

        $.post('https://properties/grabPropertyName', JSON.stringify({
            name,
            property
        }));
        return
    })
   
})

///////////////////////////////////////////////////////


var bamlItems = null,
    selectedItem = null,
    splitOpened  = false,
    splitValue = null;

selectItem = (item) => { 
    selectedItem = item;
    $('.item').removeClass('active');
    $('.item[id=' + item + ']').addClass('active');
}

// test arrays remove later 

getItemFromItemTempId = (id, obj) =>{

    for (const [key, value] of Object.entries(obj)) {

        if (value.id === id) {
            return value
        }
      }

}


withdraw = () => { 
    if (selectedItem) { 
        //var index = bankItems.findIndex((el) => el.id === selectedItem);
        var itemData = bankItems.find((el) => el.id === selectedItem);

        if (itemData) {

            $.post('https://properties/withdrawItem', JSON.stringify({
                itemData
            }));
            
        } else return false;
    } else { 
        return false;
    }
}

deposit = () => { 
    if (selectedItem) { 
        //var index = inventoryItems.findIndex((el) => el.id === selectedItem);
        var itemData = inventoryItems.find((el) => el.id === selectedItem);

       // var itemData = getItemFromItemTempId(selectedItem, inventoryItems)

        if (itemData) {

            $.post('https://properties/depositItem', JSON.stringify({
                itemData
            }));

        } else return false;
    } else { 
        return false;
    }
}

splitItem = (quantity) => {
    
    var isBank = null
    var isInventory = null

    if (bankItems) {
        isBank = bankItems.find((el) => el.id === selectedItem);
    }

    if (inventoryItems) {
        isInventory = inventoryItems.find((el) => el.id === selectedItem);
    }

    if (isBank) { 
        if (inventoryItems) {
            var alreadyExist = inventoryItems.find((el) => el.name === isBank.name);
        }
        var index = bankItems.findIndex((el) => el.id === selectedItem);

        $.post('https://properties/sWithdrawItem', JSON.stringify({
            isBank,
            quantity
        }));
    
    } else if (isInventory) { 
        if (bankItems) {
            var alreadyExist = bankItems.find((el) => el.name === isInventory.name);
        }
        var index = inventoryItems.findIndex((el) => el.id === selectedItem);

        $.post('https://properties/sDepositItemSplit', JSON.stringify({
            isInventory,
            quantity
        }));

    }

    refreshItems();
}

split = () => { 
    if (!splitOpened && selectedItem) { 
        splitOpened = true;
        $('.split-overlay').fadeIn(700);
        setTimeout(() => {$('.split-overlay').css('display', 'grid'); }, 500);
    }
}

closeSplit = () => { 
    splitValue = $('#split-value').val();
    if (splitValue == null) return false;
    if (splitValue < 1) return false;
    else { 
        splitItem(splitValue)
    }
    splitOpened = false; 
    $('.split-overlay').fadeOut(700);
}

$(window).keyup(function (e) {
    if (e.keyCode == 13) { 
        if (splitOpened) { 
            closeSplit();
        }
    }

    else if (e.keyCode == 27) { 
        if (splitOpened) { 
            splitOpened = false; 
            $('.split-overlay').fadeOut(700);
        }
    }
});

setInventoryItems = (receivedData) => { inventoryItems = receivedData; refreshItems(); }
setBankItems = (receivedData) => { bankItems = receivedData; refreshItems(); }

refreshItems = () => {
    $('.inventory-items').text(" ");
    $.each(inventoryItems, function(i, item) {

        if (item) {
            if (item.count > 0) {
                $('.inventory-items').append(
                    `<li onclick='selectItem(${item.id})' class="item" id='${item.id}'>${item.label} <b class="quantity">${item.count}</b></li>`
                );
            }
        }
    });

    $('.bank-items').text(" ");
    $.each(bankItems, function(i, item) {

        if (item) {
            if (item.count > 0) {
                $('.bank-items').append(
                    `<li onclick='selectItem(${item.id})' class="item" id='${item.id}'>${item.label} <b class="quantity">${item.count}</b></li>`
                );
            }
        }
    });
} // test function remove later 

