local stanza = require "util.stanza";
local update_presence_identity = module:require "util".update_presence_identity;

package.path = '?.lua;' .. package.path
local inspect = require('/usr/share/jitsi-meet/prosody-plugins/inspect');

-- For all received presence messages, if the jitsi_meet_context_(user|group)
-- values are set in the session, then insert them into the presence messages
-- for that session.
function on_message(event_name)
return function (event)
    -- module:log("debug", "presence identity on_message. " .. inspect(event, { depth = 2 }));
    module:log("debug", "presence identity on_message (event: .." .. event_name .. "). " .. inspect(event.stanza));
    if event and event["stanza"] then
      if event.origin and event.origin.jitsi_meet_context_user then

            module:log("debug", "updating presence identity " .. inspect(event.origin.jitsi_meet_context_user))
          update_presence_identity(
              event.stanza,
              event.origin.jitsi_meet_context_user,
              event.origin.jitsi_meet_context_group
          );

        else
            module:log("debug", "not updating presence identity");

      end
    end
end
end

-- module:hook("presence/initial", on_message("presence/initial"));
module:hook("pre-presence/bare", on_message("pre-presence/bare"));
-- module:hook("pre-presence/host", on_message("pre-presence/host"));
module:hook("pre-presence/full", on_message("pre-presence/full"));
-- module:hook("presence/bare", on_message("presence/bare"));
-- module:hook("presence/host", on_message("presence/host"));
module:hook("presence/full", on_message("presence/full")); -- this is the only one that fires now?

module:log("debug", "registered presence identity hooks");
