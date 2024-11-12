CONGRESS_NUMBER=$1
CONGRESS_INFO_FILE=congress_info.xml
CONGRESS_MEMBERS_INFO_FILE=congress_members_info.xml
CONGRESS_DATA_FILE=congress_data.xml
CONGRESS_PAGE_FILE=congress_page.html

error=0
invalid_arguments_number=0
invalid_congress_number=0
information_not_found=0

# Check if the correct number of arguments is passed
if [ $# -ne 1 ]
then
    invalid_arguments_number=1
    error=1
fi

# Check if the congress number is a valid integer between 1 and 118
if ! [[ "$CONGRESS_NUMBER" =~ ^[0-9]+$ ]] || [ "$CONGRESS_NUMBER" -lt 1 ] || [ "$CONGRESS_NUMBER" -gt 118 ]
then
    invalid_congress_number=1
    error=1
fi

# If there are any errors, exit and log the result
if [ $error -eq 1 ]
then
    java net.sf.saxon.Query "congress_number=$CONGRESS_NUMBER" "invalid_arguments_number=$invalid_arguments_number" "invalid_congress_number=$invalid_congress_number" "information_not_found=$information_not_found" ./queries/extract_congress_data.xq -o:./data/$CONGRESS_DATA_FILE
    echo Data generated at data/$CONGRESS_DATA_FILE
    java net.sf.saxon.Transform -s:data/$CONGRESS_DATA_FILE -xsl:transformations/add_validation_schema.xsl -o:data/$CONGRESS_DATA_FILE
    java net.sf.saxon.Transform -s:data/$CONGRESS_DATA_FILE -xsl:transformations/generate_html.xsl -o:data/$CONGRESS_PAGE_FILE
    echo Page generated at data/$CONGRESS_PAGE_FILE
    exit 1
fi

# Fetch congress information and members data
curl -X GET "https://api.congress.gov/v3/congress/${CONGRESS_NUMBER}?format=xml&api_key=${CONGRESS_API}" -H "accept: application/xml" -o data/congress_info.xml
curl -X GET "https://api.congress.gov/v3/member/congress/${CONGRESS_NUMBER}?format=xml&currentMember=false&limit=500&api_key=${CONGRESS_API}" -H "accept: application/xml" -o data/congress_members_info.xml

# Create the XML output using XQuery
java net.sf.saxon.Query "congress_number=$CONGRESS_NUMBER" "invalid_arguments_number=$invalid_arguments_number" "invalid_congress_number=$invalid_congress_number" "information_not_found=$information_not_found" ./extract_congress_data.xq -o:./data/$CONGRESS_DATA_FILE

# Apply XSLT transformations
java net.sf.saxon.Transform -s:data/$CONGRESS_DATA_FILE -xsl:transformations/add_validation_schema.xsl -o:data/$CONGRESS_DATA_FILE
echo Data generated at data/$CONGRESS_DATA_FILE

# Generate the HTML page
java net.sf.saxon.Transform -s:data/$CONGRESS_DATA_FILE -xsl:transformations/generate_html.xsl -o:data/$CONGRESS_PAGE_FILE
echo Page generated at data/$CONGRESS_PAGE_FILE
