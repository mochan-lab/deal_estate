var abi = [];
var address = "";

let tableSet = (dataTable) => {
  dataTable.DataTable({
    lengthChange: false,
    searching: false,
    paging: false,
    ordering: true,
    info: true
  });
};

var contract;
function startApp() {
  contract = new web3.eth.Contract(abi).at(address);
  contract.getAllReleased((error, result) => {
    let dataTable = document.getElementById('dataTable');
    result.forEach(element => {
      contract.getEstate(element)
        .then(function(result) {
          let newRow = dataTable.insertRow(-1);
          for (let i = 0; i < 5; i++){
            newRow.insertCell(-1);
          }
          newRow.cells[0].appendChild(document.createTextNode(element)); //key
          newRow.cells[1].appendChild(document.createTextNode(result[0])); //name
          newRow.cells[2].appendChild(document.createTextNode(result[1])); //address
          newRow.cells[3].appendChild(document.createTextNode(result[2])); //price
          let cell4 = "<a onclick=\"purchase(" + element + ")\">Buy</a>";
          newRow.cells[4].insertAdjacentHTML('beforeend', cell4);
        })      
    });
    tableSet(dataTable);
  })
}

let account_set = (x) => { document.getElementById('contract_init').textContent = x; }

window.addEventListener('load', function() {
  try {
    const acccounts = window.ethereum.request({ method: 'eth_requestAccounts' });
    if (acccounts.length > 0) {
      console.log(acccounts[0]);
      window.addEventListener('load', function () { account_set(accounts[0]); });
    }
  } catch (err) {
    account_set("No account!");
    console.log(err);
  }
  
  startApp()
})

let purchase = (x) => {
  contract.purchase(x)
    .then(function () {
      window.location.assign("./myEstate.html");
    })
}
