declare function local:extract-congress-info($congress-info as document-node(), $members-info as document-node()) as element(data) { 
    let $name := $congress-info//name
    let $number := $name/@number
    let $startYear := $congress-info//startYear
    let $endYear := $congress-info//endYear
    let $url := $congress-info//url
    let $sessions := $congress-info//sessions/session
    let $chambers := $congress-info//chamber
    let $members := $members-info//member

    return 
        <data>
            <congress>
                <name number="{if ($number) then $number else 0}">{data($name)}</name>
                <period from="{if ($startYear) then $startYear else 'N/A'}" 
                        to="{if ($endYear) then $endYear else 'N/A'}"/>
                <url>{if ($url) then data($url) else 'N/A'}</url>

                <chambers>
                    {
                        for $chamber-name in distinct-values($chambers)
                        let $chamber-name-text := data($chamber-name)  
                        let $chamber-sessions := $sessions[some $s in . satisfies ($s/chamber = $chamber-name-text)]
                        
                        let $chamber-members := 
                            for $member in $members
                            let $member-chambers := $member/terms/item/item/chamber
                            where some $chamber in $member-chambers satisfies $chamber = $chamber-name-text
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
                                        return
                                            for $term in $terms
                                            let $member-periodStart := $term/item/startYear
                                            let $member-periodEnd := $term/item/endYear
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
                                            let $session-name := $session/name
                                            let $session-period := $session/period
                                            return
                                                <session>
                                                    <name>{data($session-name)}</name>
                                                    <period from="{if ($session-period/@from) then $session-period/@from else 'N/A'}" 
                                                            to="{if ($session-period/@to) then $session-period/@to else 'N/A'}"/>
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
