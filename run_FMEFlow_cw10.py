import requests
import maskpass

url="http://HP-ENVY-X360-NA/fmejobsubmitter/Dashboards/cw10.fmw?EMAIL=natii7410%40gmail.com&PASSWD=\"tftk cacd ehab xsrp\"&C_EMAIL=natii7410%40gmail.com&POWIAT=radomski&CCOV=20&START_DATE=20230918000000&END_DATE=20230924000000&SourceDataset_SHAPEFILE=C%3A%5CUsers%5Cnatii%5COneDrive%5CPulpit%5Cswoje%5C00_jednostki_administracyjne%5CA02_Granice_powiatow.shp&opt_showresult=false&opt_servicemode=sync"
username = input("Enter your FME Flow username: ")
password = maskpass.askpass(prompt="Enter your FME FLow password: ", mask="*")

response = requests.get(url, auth=(username, password))

if response.status_code == 401:
    print("Brak autoryzacji")
elif response.status_code == 200:
    # Process the response data
    info = response.text
else:
    # Print an error message or handle the authentication issue
    print(f"Error: {response.status_code} - {response.text}")

print(response.text)