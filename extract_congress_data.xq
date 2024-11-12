declare function local:extract-congress-info($congress-info as document-node(), $members-info as document-node()) as element(data) {
    let $name := $congress-info//name
    let $number := $name/@number
    let $period := $congress-info//period
    let $url := $congress-info//url
    let $chambers := $congress-info//chamber
    let $members := $members-info//member

    return 
        <data>
            <congress>
                <!-- Ensure number attribute exists and is integer -->
                <name number="{if ($number) then $number else 0}">{data($name)}</name>
                
                <!-- Ensure period attributes exist -->
                <period from="{if ($period/@from) then $period/@from else 'N/A'}" 
                        to="{if ($period/@to) then $period/@to else 'N/A'}"/>
                
                <!-- Ensure URL exists -->
                <url>{if ($url) then data($url) else 'N/A'}</url>
                
                <chambers>
                    {
                        for $chamber in $chambers
                        let $chamber-name := $chamber/name
                        let $sessions := $chamber/sessions/session
                        return
                            <chamber>
                                <name>{data($chamber-name)}</name>
                                <members>
                                    {
                                        for $member in $members
                                        let $member-name := $member/name
                                        let $state := $member/state
                                        let $party := $member/partyName
                                        let $image-url := $member/depiction/imageUrl
                                        let $member-period := $member/terms/item/item/period
                                        return
                                            <member bioguideId="{data($member/bioguideId)}">
                                                <name>{data($member-name)}</name>
                                                <state>{data($state)}</state>
                                                <party>{data($party)}</party>
                                                <image_url>{data($image-url)}</image_url>
                                                
                                                <!-- Ensure correct order: number before period -->
                                                <period from="{if ($member-period/@from) then $member-period/@from else 'N/A'}" 
                                                        to="{if ($member-period/@to) then $member-period/@to else 'N/A'}"/>
                                            </member>
                                    }
                                </members>
                                <sessions>
                                    {
                                        if (count($sessions) > 0) then (
                                            for $session in $sessions
                                            let $session-number := $session/number
                                            let $session-type := $session/type
                                            let $session-period := $session/period
                                            return
                                                <session>
                                                    <!-- Correct order: number before period -->
                                                    <number>{data($session-number)}</number>
                                                    <period from="{if ($session-period/@from) then $session-period/@from else 'N/A'}" 
                                                            to="{if ($session-period/@to) then $session-period/@to else 'N/A'}"/>
                                                    <type>{data($session-type)}</type>
                                                </session>
                                        )
                                        else (
                                            <session>
                                                <number>0</number>
                                                <period from="N/A" to="N/A"/>
                                                <type>N/A</type>
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
