declare variable $invalid_arguments_number as xs:integer external;
declare variable $invalid_congress_number as xs:integer external;
declare variable $information_not_found as xs:integer external;

declare function local:extract-congress-info($congress-info as document-node(), $members-info as document-node()) as element(data) {
    let $name := $congress-info//name
    let $number := $name/@number
    let $startYear := $congress-info//startYear
    let $endYear := $congress-info//endYear
    let $url := $congress-info//url
    let $sessions := $congress-info//sessions/item
    let $chambers := $congress-info//chamber
    let $members := $members-info//member

    return 
        
        <data>
        if(($invalid_arguments_number,$invalid_congress_number,$information_not_found)!=0) then
                if($$invalid_arguments_number!=0) then <error>this script reads exactly one argument</error> else ()
                if($$$invalid_congress_number!=0) then <error> congress number must be between 1 and 118</error> else ()
                if($$$information_not_found!=0) then <error>we couldn't retrieve the information</error> else ()

        else
            <congress>
                <name number="{if ($number) then $number else 0}">{data($name)}</name>
                <period from="{if ($startYear) then $startYear else 'N/A'}" 
                        to="{if ($endYear) then $endYear else 'N/A'}"/>
                <url>{if ($url) then data($url) else 'N/A'}</url>

                <chambers>
                    {
                        for $chamber-name in distinct-values($chambers)
                        let $chamber-name-text := data($chamber-name)  
                        let $chamber-sessions := 
                        for $session in $sessions
                        where some $chamber in $session/chamber
                            satisfies normalize-space($chamber) = normalize-space($chamber-name-text)
                        return $session
                        
                        let $chamber-members := 
                        for $member in $members
                        where some $chamber in $member//terms/item/item/chamber
                            satisfies normalize-space($chamber) = normalize-space($chamber-name-text)
                        return $member

                        return
                            <chamber>
                                <name>{data($chamber-name)}</name>
                                <members>
                                    {
                                        for $member in $chamber-members
                                        let $member-name := $member/name
                                        let $state := $member/state
                                        let $party := $member/partyName
                                        let $image-url := $member/depiction/imageUrl
                                        let $terms := $member/terms/item
                                        let $member-periodStart := $terms/item/startYear
                                        let $member-periodEnd := $terms/item/endYear
                                        return
                                            <member bioguideId="{data($member/bioguideId)}">
                                                <name>{data($member-name)}</name>
                                                <state>{data($state)}</state>
                                                <party>{data($party)}</party>
                                                <image_url>{data($image-url)}</image_url>
                                                <period from="{if ($member-periodStart) then $member-periodStart else 'N/A'}" 
                                                        to="{if ($member-periodEnd) then $member-periodEnd else 'N/A'}"/>
                                            </member>
                                    }
                                </members>

                                <sessions>
                                    {
                                        if (count($chamber-sessions) > 0) then (
                                            for $session in $chamber-sessions
                                            return
                                                <session>
                                                    <number>{data($session/number)}</number>
                                                    <type>{data($session/type)}</type>
                                                    <period from="{if ($session/startDate) then $session/startDate else 'N/A'}" 
                                                            to="{if ($session/endDate) then $session/endDate else 'N/A'}"/>
                                                </session>
                                        )
                                        else (
                                            <session>
                                                <name>N/A</name>
                                                <period from="N/A" to="N/A"/>
                                            </session>
                                        )
                                    }
                                </sessions>
                            </chamber>
                    }
                </chambers>
            </congress>
        </data>
};

let $congress-info := doc("congress_info.xml")
let $members-info := doc("congress_members_info.xml")
return local:extract-congress-info($congress-info, $members-info)
