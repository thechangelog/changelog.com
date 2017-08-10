**Adam Stacoviak:** Welcome back everyone, this is The Changelog and I am your host, Adam Stacoviak. This is episode 200 - that's right, the big 2 0 0. I'm excited about that, because we actually had Raquel Vélez on this show. If you don't know Raquel Vélez, she's Rockbot pretty much everywhere out there. We talked to her about where she came from, how she got into programming with Javascript, her passion for robots and mechanical engineering, and also the culture of Npm.

We have three sponsors for this show - Toptal, Linode and Full Stack Fest.

Our first sponsor for the show today is our friends at Toptal. If you're new to the show, let me tell you, we love Toptal. If you've been listening for a while now, you know that we love Toptal.

Toptal is an exclusive network of top freelance software developers and designers. Top companies every single day rely on Toptal freelancers for their most mission-critical projects. One of the things we love about Toptal is that it's this worldwide community of engineers and designers that just love to enrich the community. As a Toptal engineer or designer you'll have the flexibility to travel the world, be able to blog on their blog, be able to apply for open source grants and contribute back to things you really care about. Head to Toptal.com to learn more, or for a more personal introduction e-mail me, adam@changelog.com I'd love to help you take your first step with Toptal. And now, onto the show.

Alright everyone, we've got a fun show lined up today. Raquel Vélez is here, and it's an interesting story to this show because we had a schedule a couple of days ago that didn't work. Long story short, if you haven't been following along, we shared it in our e-mail, we shared it on Twitter, I shared it on my personal Instagram and elsewhere on the internet, but my wife and I, we had a kid, so it's been a kind of craziness for us. It's always fun to have a kid, but it's crazy times the first couple months.

Jerod, we've got Raquel here, aka Rockbot. What do you think, man?

**Jerod Santo:** I'm excited, and I think you probably haven't heard it yet, but I congratulated you on the start of our last show. I just wanna reiterate that, for you and Heather. Exciting times at the Stacoviak house!

**Adam Stacoviak:** Yes, a new changelogger in the system - love it!

**Jerod Santo:** But, we have Raquel here. Raquel, welcome to the show!

**Raquel Vélez:** Thank you! Hello, and congratulations! Oh my god!

**Adam Stacoviak:** Thank you.

**Raquel Vélez:** ... a little human.

**Adam Stacoviak:** Yeah, it's the craziest thing. They come out and they become humans, isn't that crazy? Well, they're human all along, of course.

**Raquel Vélez:** Well, I don't know, they start out kind of nugget-shaped, and slightly lizardy, and then eventually over time they become more human.

**Jerod Santo:** What we could do is we could argue about exactly when that moment is.

**Raquel Vélez:** Or, we could talk about pretty much anything else.

**Jerod Santo:** Yes, pretty much anything else. So let's talk about this - I'm not sure if you saw this or watched it, but you were a feature prominently on our Beyond Code interview series, which is actually how I found out about you, Raquel. It's a video series we do, where we interview people at conference after-parties, and we ask everybody the exact same five or six deep questions, and watch them squirm and watch them have fun answering those. In season two - we'll link it up in the show notes - we had Amanda Shih, and we asked her who her programming hero is, and she had this response, which is actually probably my favorite moment in Beyond Code so far... \[\\00:04:01.14\\\]

**Adam Stacoviak:** Yes, I agree. We have a clip, so let's go ahead and play the clip, and we'll let you all hear that.

"That's a hard one. I have to say I have kind of a developer crush on Raquel. I'm pretty sure she doesn't know that I have a crush on her, but I think she's pretty awesome, she does robot stuff. Yeah, that would be one... There's a lot. I like looking up to people, and I think it's good to be inspired by people, but she's one that I can think off of the top of my head."

**Jerod Santo:** I was interviewing her at that time, and I just had to kind of act like I knew who Raquel was, \[laughter\] because she didn't specify, and I'm like "Cool, good answer." Then I'm like, \[whispering\] "Adam, who's Raquel?"

**Adam Stacoviak:** \[whispering\] Wait, that's Rockbot, from npm.

**Jerod Santo:** \[cross-talk 00:04:46.00\] Rockbot, I'm like, "Oh, okay." So that was a fun way of introducing you to us. Just curious how you feel being someone who Amanda Shih thinks is pretty awesome, and even so much to have a developer crush on you.

**Raquel Vélez:** Yeah, I saw a tweet along those lines, and I think I saw the video. I sat there staring at my monitor, being like, "Oh my god, this is adorable!" I'm honored, honestly. I think it's so heart lifting and just warm-fuzzy-feeling-y that... How can you possibly say anything negative about that? That is just so cool. I was on a speaker panel the other day, and they asked me what got you into speaking. A lot of people are like, "Well, the reason I started speaking is because I wanted to prove that I understood something" or "I wanted to get over my fear of public speaking" or whatever, and for me one of the biggest reasons - there's this really amazing quote that I've heard from lots of different sources, so I don't know who to attribute it to, but "You can't be it if you can't see it." So I was sick and tired of seeing the same type of person on stage at tech conferences, and I was like, "You know what? Forget it... I need more people who look like me on stage, so I'm gonna go and just be on stage. Let's just do this." So hearing other people kind of recognize that "I'm out there, I'm doing stuff", that's just super cool, and I love that. It feels really warm, fuzzy. Yay!

**Adam Stacoviak:** Plus she was totally into robots, too. I think everybody there mentioned Johnny-Five.

**Raquel Vélez:** Yeah, which is...

**Jerod Santo:** It was a Javascript conference, so there was a lot of -- it was down in Houston, right? - so there was a lot of Node and NodeBots people in the house.

**Adam Stacoviak:** Yes, quite following you have.

**Jerod Santo:** And just to give you a brief introduction for you, just for our listeners, Raquel, you work at npm and you've been very active in the NodeJS and NodeBots community. When you're asked to introduce yourself, I noticed on your website, you have like four or five versions of your bio, which I thought was kind of funny... How do you introduce yourself?

**Raquel Vélez:** I basically say "Hi, I'm Raquel Vélez, I'm @Rockbot on Twitter" - which always feels weird, because people are like "Why does anybody care about your Twitter handle?" except that so many people know me as Rockbot. They won't know my name, but they'll know my Twitter handle. So I'm like, "Hey, I'm rocbot, I work at npm, I work on the web team. One of my claims to fame is that I was employee number one at npm, so I've been there the whole time with the company." And then from then, things can go haywire; I can say so many things. \[laughter\] I was a huge, huge part of the NodeBots movement; I was one of the original, core members of NodeBots, and I still cheerlead on the sidelines. \[\\00:08:06.14\\\] I've taken a little bit of a hiatus... I've been doing it for three years and there are so many incredible people who have taken up the torch, that I want them to get the recognition, because I'm not doing it as much anymore.

Other things... What other things do I wanna tell people? I generally tell people that I just love to geek out and nerd out on stuff, but I don't know...

**Adam Stacoviak:** What about your podcast?

**Raquel Vélez:** Oh yeah, I have a podcast - Reactive.audio. It's a weekly podcast where we basically - three people - hang out and chat about what happened over the last week in tech. It tends to have a bit of a Javascript angle, but we'll talk about pretty much anything. In my offtime I tend to -- I actually have started stepping away from the technology as much as I can, just because my work at npm is so intense that it's nice to take a complete break. Fun fact - I have a degree in Mechanical Engineering, and so the software stuff is really fun, but I miss working with my hands. So in the last year or so I've started taking up things like sewing and knitting, which to me is just mechanical engineering with fabric or yarn, and it's super cool to me, doing all this engineering in three-dimensional space, as opposed to...

**Adam Stacoviak:** What kind of stuff do you make?

**Raquel Vélez:** Clothes, actually... Because clothes are hard...

**Adam Stacoviak:** Baby clothes?

**Raquel Vélez:** No...

**Adam Stacoviak:** I was trying to get some baby clothes, I'm sorry...

**Jerod Santo:** You're trying to get some freebies, or what?

**Adam Stacoviak:** Yeah.

**Raquel Vélez:** Yeah, I mean... The thing about baby clothes that's so weird is that babies grow so fast...

**Jerod Santo:** Yeah...

**Adam Stacoviak:** It's a waste of time. You wear it for a month and you're done.

**Raquel Vélez:** Yeah, exactly.

**Jerod Santo:** I think that a Netflix for babies is a really good idea... I mean Netflix clothes, because you're constantly trading up, and I'm sure that \[unintelligible 00:10:07.14\]

**Raquel Vélez:** That makes sense.

**Jerod Santo:** So you're making clothes... You mentioned you have this different background and actually just looking at one of your bios - you've lived in four different countries, you speak five different languages, so you're polyglot in the traditional sense of polyglot...

**Raquel Vélez:** Yeah.

**Jerod Santo:** We like to learn how people came to where they are, and especially you being now such a prominent member of the open source and Javascript community, I was surprised to find that you're kind of relatively new to it in terms of your overall history. Can you take us back to this degree in mechanical engineering and how you got from there to a software developer at npm, Inc.?

**Raquel Vélez:** Absolutely. First of all, we have to do the Wayne's world intro...

**Jerod Santo:** Yes! Very good, I like that.

**Raquel Vélez:** So let's see, how do we start? So I got a degree in Mechanical Engineering from Caltech, which is a pokey little tech school in Southern California. I was really into robots. My whole undergraduate career was all about robots. In robotics you can do either Mechanical Engineering, Electrical Engineering or Computer Science. Electrons and I don't get along, so that was out, and Computer Science just seemed really, really... Like, I didn't get to play with my hands, it was all extremely mathy and... I don't know, the Computer Science nerds - no offense to Computer Science nerds, but I didn't get along with them in the same way that I got along with Mechanical Engineering nerds, so I was like "Alright, Mechanical Engineering, it's like arts and crafts with big machines, let's do this." So I did that, but hilariously, over the course of doing all the mechanical engineering and doing robotics, there was always a need for more people to program stuff, and I got really interested in the artificial intelligence side of robotics, so I did a lot of programming just because I wanted to make the robots think. \[\\00:12:12.25\\\] But I never thought of it as Computer Science. Computer Science was for the really theoretical, pushing computers and computational mathematics into a whole new realm. I was just programming.

So that was cool, that was fun; I did that for a really long time. Then eventually I got a little bit burnt out on robotics, because they don't really talk back, and if they do, something's very wrong. So I just was like, "Okay, I'm gonna take a little bit of a break from this", and I was the CTO of a little startup that ran out of money eventually - thank goodness... Because I had no business being a CTO.

But I thought, you know, "I have a degree in Mechanical Engineering from Caltech, I've built robots. I could totally be a CTO of a web company?" No, no, I could not. That was terrible.

So that ended, and I was like "Okay, you know what? CTO is a little bit too big for me, but let me try something a little bit easier." I had this vision of what I wanted the internet to be like. I had this vision of walking into a room and having this wall-sized screen where I could just kind of say, "Hey, take me to Target. I wanna buy a few things", without any sort of keyboard, mouse, or anything like that. Something like that movie where Tom Cruise has the gloves, and he can...

**Adam Stacoviak:** Minority report...

**Jerod Santo:** Minority report?

**Raquel Vélez:** Minority report, yeah. So I was kind of thinking something along the lines of Minority Report, where I could scan through different things, and it was like this whole three-dimensional experience. And I was like, "That sounds really cool, I wanna build that." And I was getting into websites, because I kept coming with new ideas for companies, because... I don't know, I just thought I should just make a new company all the time - that was also a bad idea. But eventually I was like, "Okay, let me get into this website thing. Surely that can't be that hard." CTO-ing was a little bit out of my elements, but I have a degree in Mechanical Engineering from Caltech, I should totally be able to handle this whole internet thing. Yeah, I was an idiot. \[laughter\] Anyway...

**Adam Stacoviak:** That's like your internal thought process: "Because I have this, I should be able to do that."

**Raquel Vélez:** Obviously, right? Like how hard can it...

**Adam Stacoviak:** And also your humble, retrospective perspective of it, too...

**Raquel Vélez:** Of course... So what I did was I asked a bunch of my friends - I was living in Charlotte, North Carolina at the time, and there were a bunch of people who were into Ruby on Rails and Javascript and whatever, and I was like, "So what do I do? How do I get into this?" They were like, "Well, you know, just ask around." I was like, "You know what? Okay." I identified what I considered to be the 'coolest company in town' and what I did was - totally fearless - I just called up the CEO of the company and I was like, "Hey, can we sit down for coffee? Let's chat." Then I was like, "Hey, how do I get a job at your company?"

At the time, Node was just kicking up. This was the end of 2011, early 2012. So he was like, "So, Node. If you can program in Node, I will hire you." I was like, "Alright, I have no idea what Node is, but let's do this." So I sat down and - I kid you not - over the course of three weeks just started everything I could about Node and HTML and CSS and everything. It was overwhelming, but I still did the - they had a little code challenge for engineers... \[\\00:16:03.09\\\] I did the best I could, and they rejected me. I was like, "This is stupid. I learned everything I needed to learn and they still rejected me." But then somebody at the company saw my application, and was like "Oh, this is interesting." I should also note that I had sent in along with the code challenge some previous code I had written. I had attempted Javascript two years prior, and I wrote something... I created a hand, an actual human hand, all in canvas, HTML and JS and CSS and stuff. I made it so that you could move all the joints in the hand, and have it be a perfect hand model. It was the crappiest Javascript you've ever seen in your life, because I didn't know Javascript; I knew C++. So I wrote Javascript like it was C++ and it was a nasty mess. Looking back on that code, you're like "Oh my god, what is this...?" But it was still really cool, and there was somebody at the company who was like, "Wow, she has potential."

So he calls me up and he's like, "Hey, do you wanna do an internship? We've never done an internship before, but you could be a good intern." So I went in and put everything in like a little humble bag, and I was like "Alright. I have worked at companies like NASA and MIT, and now I'm gonna be an intern for $500/week, and learn this Javascript, Node, HTML internet thing..." It was supposed to be a six-week internship; after five weeks they hired me on full-time. I was a junior developer, and then I just learned everything I could.

It was a consulting company, so they had me doing some PHP, some Javascript, and all sorts of things. And I was like, "You know what, I really like Node." Oh, I went to a NodeConf summer camp in 2012, which was kind of the jumping off point for my career, because I met a whole bunch of people in the Node community. This was NodeConf summer camp 2012 - there was a hundred people there. 90% of the people who were huge figures in Node were there, at that event. I met them and I got to know them. That was where I met Isaac for the first time, it's where I met all sorts of people. I mentioned Isaac because he's important too later in the story.

And I was like, "These people are amazing, but they're all living on the West Coast, in the Bay Area." So my husband and I got married and three weeks later I was like, "You know what? Let's move to San Francisco" and he was like, "Okay!" And I was like, "Yes, let's do this!" So I got a job at a startup in San Francisco - it was all in Node. So I just slowly moved my way up. After six months there I moved to another company, and then about six months into that second position... So all the while I'm giving talks and I'm going to more Node events, and I'm just really getting to know everybody in the community. At this point I've already started -- I should backtrack a little bit... At NodeConf summer camp 2012 I also met Chris Williams, who is the curator of JSConf US. I met him and somehow he learned through grapevine that I used to build robots, and he was like "Hold up! We need to talk about this." Because he created Node Serialport, which is the interface by which you can use Node to talk to serial devices, which is a huge component to NodeBots. \[\\00:20:03.01\\8\] And he had hung out with Rick Waldron, who is the creator of Johnny-Five, and he was like, "We need to talk about this, because you actually know robotics. The rest of us know Javascript, and we wanna get into robotics, and you know robots and wanna get into Javascript. So let's see if we can make something happen."

**Adam Stacoviak:** A merging of the minds, basically.

**Raquel Vélez:** Yeah, exactly. And he was like, "I want you to speak at JSConf. Put in a proposal, let's talk about robots." Then my proposal got accepted, and he was like, "Also I want to do a NodeBots workshop." So my very first major conference, I not only gave a talk but also ran a workshop. That was when NodeBots was really born, and we can talk all about that. But meanwhile, I'm doing this NodeBots thing, I'm working in San Francisco, and then I get an e-mail from Isaac Schlueter, creator of npm and at the time the Benevolent Dictator For Life of Node (BDFL) and he was like, "Hey, I'm spinning npm into a company, and I'd love for you to join." And I was like, "How do you know who I am?" I mean, obviously he knew who I was because he'd seen me at all of these different events and we had a lot of friends in common; we were semi-friends as well, and it was just kind of like this amazing opportunity, and I was like, "Alright, let's do this!"

**Adam Stacoviak:** So you were employee number one.

**Raquel Vélez:** I was employee number one. I've been there for over two years now, and it's been a constant series of learning. Just learning more, and more, and more, and more. It is really shocking that I've only been in this industry for four years. I started in 2012 and it's now 2016. Most of the people that I work with have been in this industry for 10-20-25 years, and I'm like, "Hi, I've been doing this for not very long at all." But I think it helps that I did so much robotics before, so I understand the concepts of programming.

One thing I'm super proud of is I knew Git before everybody else knew Git, because we were using Git in robotics, before the web world was using Git. So when I walked in and people were like, "Do you understand source control?", I was like, "You mean Git, or Subversion? What do you want, I got'em all." And they were just like, "Oh no, we use Git. There's a thing called GitHub", and I was like, "What? Are you serious? There's a thing called GitHub? There's a platform, an online place where you can do the Git stuff in the cloud? What -- this is so much better."

**Adam Stacoviak:** The Git stuff!

**Jerod Santo:** Nice.

**Raquel Vélez:** Because we used to just have our own internal servers, and we had to get to the different servers... And I was like, "Oh my god, I'm actually old-school in something." \[laughs\]

**Jerod Santo:** That's awesome.

**Raquel Vélez:** So that was cool.

**Jerod Santo:** I'm sitting here listening to this story, and I'm trying to characterize you in light of it, and you keep saying this statement, "I have a Mechanical Engineering degree from Caltech, so I can do this." I seem to think of you as - the word that keeps coming to mind is 'intrepid'. You have this fearless, adventurous side or characteristic about you which seems to have lead you down this path, and I just want to tee this up for you and we'll talk about it on the other side of the break, which is where did that come from? Did you come out of the womb in this way, or did somebody instill into you this idea that you can succeed, despite the odds or despite the circumstances? You seem to be outside of your comfort zone, but yet you just plow forward. So don't answer now; we'll take a break, so why don't you think about it a little bit, and on the other side tell us, where did this intrepid attitude come from? We'll be right back.

**Break:** \[\\00:24:03.04\\\]

**Jerod Santo:** Alright, we are back with Rockbot, as she is lovingly known on the internet. Raquel, before the break you kind of gave us your history of how you moved from this degree in Mechanical Engineering to employee number one at Npm. First of all, do you think that's a fair interpretation of a characteristic of you, which is that you have this fearless, adventurous, intrepid outlook on life where it seemed you kind of just barreled into opportunities, despite perhaps the odds being against you, or being in over your head? So the first part would be do you think that's fair, or you think I've mischaracterized you? And secondly, if it is fair, where does it come from?

**Raquel Vélez:** Yeah, so I have to say... I think it's a fair characterization externally. Internally, I'm terrified. Constantly, totally, utterly terrified every single step of the way. But I have this analogy -- I'm really big on analogies, so no apologies... If you're standing at a beach and you know that there's something out in the water, there are people who are gonna be like, "Oh my god, it's too scary, I don't wanna swim", and they'll just kind of hang out on the beach. Then there are people who are like genuinely fearless, who just go straight forward. I'm the type of person who sits there on the beach and is like, "Oh my god, this is terrifying, but what I want is over there, in the ocean", so I take a really deep breath and be like, "This scares the living everything out of me, but I'm going for it anyway", and then I just go for it. There are some people who just get lifted up and dropped into the middle of the ocean and are forced to swim - that happens to me sometimes, but I like to be in control, so I tend to be the type of person who's like "This is terrifying, but if I don't go for it, then who will? And no one else is gonna give this to me."

As from where that came from, I think a lot of that really does come from my family, from my mother... My family is from Porto Rico, and both of my parents grew up really poor, but they managed to get degrees in Chemical Engineering, and they eventually worked their way up and are now thriving and living happily with their degrees and doing lots of great things, and they own their own business etc. \[\\00:28:21.22\\\] So it was never an option for me to just kind of sit still and let things happen. It's very much been a "Well, what do you want?" For me, I think, trying to figure out what I want... In pre-school - I'm part of the generation of children who, for reasons completely unknown to me, teachers have decided to add graduations at every ridiculously silly, menial opportunity. So I had a pre-school graduation - I don't know why, but I did - and I was always the type of person who wanted to be at the center of attention. We had to do a class song, and I was like, "Well, they can't hear me." My mother loves telling this story of how I felt like no one could hear me, so I just walked up to the microphone and grabbed it for myself, and just started singing so that everybody could hear me, because otherwise I'd be lost in the crowd. That's silly, I don't wanna be lost in the crowd; I want people to know who I am.

**Adam Stacoviak:** That's a good metaphor. It's the truth, but it's also a good metaphor for life.

**Raquel Vélez:** Yeah, exactly. So when I was first thinking about like, "Should I get into this Node thing or not?" I genuinely was like, "Well, this thing is new enough. I could probably work my way up to the top. It's such a small community right now, I could probably get there and be known. Like, people would recognize who I am", and as we have found, that has worked out in my favor. I went out of my way... When it comes to meeting people, I'm extremely purposeful about who I'm meeting, when I'm meeting them... I try really hard not to be disingenuous. I like to think I'm really genuine about... When I'm meeting someone, I genuinely want to meet them and get to know them, and become friends if that's in the cards; or if we're not gonna be friends, then we're just not gonna be friends, that's fine. But I don't go out of my way to be friends just for the sake of networking and working my way up, but I do know who's gonna be in the room before I walk into it. I try to figure out, "Okay, who's here, who can I get to know, can I become friends with them?" but with the added side-bonus of "Hey, if things work out, I could move up."

So that was very much my motivation, in a lot of ways not only for myself to be the person who is heard, but again, like I mentioned before, there aren't a lot of people out there that look like me on these stages, in these communities, leading these communities, and if I'm not the person to do it, then who will? And there's so many people who look like me who aren't at these leadership positions because they've never seen anybody who looks like them in those leadership positions. So again, if I don't do it, who will? It terrifies me, I cannot tell you how scared I am all the time, but at the same time, you can't grow unless you step out of your comfort zone. So I'm taking every single bit of it for myself, but with the added benefit of helping other people as well.

**Jerod Santo:** It's funny you mentioned that you had this moment where you kind of take a deep breath and jump into the water so to speak, and I've noticed that you do write pretty prolifically on your blog - you have 24 pages of archives, which is pretty good by any measurement - over the years... \[\\00:32:08.13\\\] I went back to your very first post, because I always think those are the interesting ones to read, and you mentioned that you kind of got in the industry in 2012 - well, your first post was 2011; it may have been near the end of the year, but it was titled Smart Latinas Get The Party Started. I read it, and it's almost that moment where you're taking a deep breath because the content of the post is very much motivational speaking almost to yourself about writing this, and putting this out on the web. Do you remember writing that post? Was that your deep-breath moment?

**Raquel Vélez:** Oh, absolutely. That was a moment where I was like, I need to just own this, because it's so easy to sit in the back seat and just be like, "I'm just going for the ride, let's just see what happens to me." I was tired of it, I was in a position where I was like, "I don't feel like people are taking me seriously, and I'm sick of it. So now what do we need to do? We need to step up and make this thing happen."

If it was late 2011 - and I believe it was - I think it was that moment when I was like, "Alright, I'm at a crossroads. I've gotta decide what I'm gonna do next. Let's just do this, let's go for it." That was definitely... That was one of those moments when I was like, "Alright, I need to learn about this internet thing. I gotta get into this. Let's see what happens."

**Jerod Santo:** Let's get the party started.

**Raquel Vélez:** Yeah.

**Adam Stacoviak:** How were you not being taken seriously?

**Raquel Vélez:** Oh goodness, so many ways... Okay, so everything from the fun stories from college, right? I was one of the very few women in my major - there aren't a lot of women mechanical engineers, I think. I think the ratio was like 10:1 in my class, just in Mechanical Engineering. There were a bunch of biologists who were women, and that's cool too, but in my classes specifically, I would be one of the three women in the room. And there are just these little things... When I first started college I was like, "Okay, the civil rights movement worked, feminism happened, we're good. Everybody's on equal playing field." And then there are these little things where you start to realize... Like, you know the answer to the homework question, but nobody's asking you. You're like, "Hey, I know the answer", and they're like "Yeah, yeah..." and then they start asking somebody else. Or the people in charge of the shop - because in Mechanical Engineering you have to take shop classes - they tell all the guys, "Hey, go to it, good luck", and then they'll come over to you and say, "So here's how to use a drill press", and you're like, "Bitch, please. I've been using power tools since I was like seven. Don't do this to me."

**Adam Stacoviak:** \[laughs\] That's awesome.

**Raquel Vélez:** And then like there are moments where you're just like, "I don't get it... How is it possible that people just don't understand? I am just as smart as everybody else here." And it didn't help. There was only that one person who's like, "You do realize you only got here because you're Hispanic and female, right?" And you're like, "No! No, I got here just the same as you did. I worked my ass off! No. No, no, no!" So little things like that, and it continues, and it continues to this day, and you're like, "Man, I'm so tired of this." People just ask you different questions... When you come down after giving a talk, sometimes people will be like, "Oh, so actually this is what I've learned... You're wrong. \[\\00:36:09.04\\\] It's great that you got up on stage and said all these things, but actually..." and you're like, "Oh, shut up!" Like, you didn't get up on stage, I did, so why don't you let me be the expert, and you just shut up and sit down?

So lots of little things... In particular, I was at that particular time when I wrote that post, Smart Latinas Get The Party Started. I was a CTO, and I would walk around in a business suit in downtown Charlotte, and people would be like, "Oh, you're adorable. You think you can be a CTO... That's so cute." And to be fair, I had no business being a CTO.

**Jerod Santo:** Yeah, by your own admission.

**Raquel Vélez:** By my own admission. But at the same time, I know lots of dudes who have no right to be a CTO, and they never got any crap like that. Just walking into the room, people would just kind of look at you funny, like "What are you doing here?" and I haven't even opened my mouth at all.

**Jerod Santo:** So do you feel like you've made it over that hump, or are you still treated that way in many contexts?

**Raquel Vélez:** In some ways, it really depends on the context. I'm at the point now where giving talks - I've made enough of a name for myself that people get really excited that Rockbot is speaking at a conference; they get really stoked, because they're excited to learn something mind-blowing, or whatever. I should also note though that I've spent a lot of time doing extremely technical talks to prove myself. I don't know that that's necessarily something that other people do. I very, very actively try not to give talks on diversity and things like that, just because I wanna make sure that I'm pigeonholing myself into, "Here's a super technical person, regardless of anything else." That said, of course I still care about diversity and inclusion, and I talk a lot about that one on one. I just don't do it necessarily in a public forum.

I've also been told that once I open my mouth, people cannot doubt that I know what I'm talking about... \[laughs\]

**Jerod Santo:** Just the way you deliver, or what do you mean?

**Raquel Vélez:** Yeah, people would be like, "Oh, so do you work with computers?" and I'm like, "Yeah, actually I work at Npm..." and then I just start spewing lots of technical jargon, and people are like, "Oh... Yeah, okay, you're not an idiot." No, I'm not an idiot. \[laughs\]

**Adam Stacoviak:** I cannot stand people who make assumptions about people, that just kind of come at them with this negative attitude about what they know. My wife deals with the same thing all the time as a designer. She's a really good designer, and she's always telling me very similar stories; similar perspective, but obviously different talents. This perspective that because of your gender, because of your background, because of where you came from, you can't possibly lead this team, you can't possibly do this very well. And they treat you like some sort of delicate thing - she is delicate, because she's a woman, but she's also very strong and very passionate, and very capable. And I cannot stand how it's like that. It drives me crazy.

**Raquel Vélez:** No, it's one of those things... It's not limited to just gender, it's not limited to just race, there's so many things... I can't tell you the number... One of the beautiful things about working at Npm is I would say our average age as a company is probably in the high thirties, which is really rare for startups. \[\\00:40:04.03\\\] The stereotypical startup is like a bunch of 22-year-old guys eating ramen while sleeping in bunk beds. But we're not, we're over 30. Everybody I work with is just phenomenally brilliant, but it's interesting to see how some of them will walk into groups, and they're like "Oh, you're older..." and they're like, "Oh my god..." This person knows so much more than you do, has been doing this for the entirety of your life, so shut up and listen, you might learn something. \[laughs\]

**Adam Stacoviak:** Let's tell this into some motivation, I guess. We've got four minutes until the break, so let's give a snapshot... We heard about your background obviously, and obviously some of the negativity towards reaching your goals, and you being self-assured to the point where you actually reach your goals, which is awesome... But you got a degree in Mechanical Engineering, you're not doing that directly - now I guess you kind of are with the robots piece, and we'll talk a bit about that probably just after the break, but could you tie in what was your motivation to go towards Javascript? I know you mentioned the...

**Jerod Santo:** Robots can't talk...

**Adam Stacoviak:** Yeah, robots can't talk... \[laughter\] You mentioned talking to the CEO and what not, but I didn't hear what motivated you to do that. Was it just the fact that it was a goal to reach for you? Help us with the motivation piece, and just after that we'll have a break and we'll come back and we'll talk about robots, and deeper about what you're doing at Npm.

**Raquel Vélez:** Yeah, so the Javascript was really just more of a means to an end. It was an opportunity. The CEO said, "Learn Node" and I was like, "Okay", and Javascript has made sense. I think a lot of people struggle with the asynchronicity of Javascript, and for some reason my brain clicked almost instantly - it's a little bit rare amongst people who are just learning Javascript - and it was so much fun for me. I loved the instant gratification of working on the web and seeing my changes in real time, as opposed to having to wait and compile, and hope that you didn't have a bug so that you don't have to compile again - sort of the iterative approach.

**Adam Stacoviak:** So it was about the speed.

**Raquel Vélez:** It was. It was about the speed, it was about just the ease of use, the fact that I could play with it immediately in the browser; I didn't have to add any news stuff to my computer. And at that company that I finally did start working at I was exposed to other languages, like PHP and a little bit of Ruby and stuff like that, and I don't know, Javascript is just \[unintelligible 00:43:07.04\] in a really fun way, and I was like, "I'm just gonna keep getting good at this." I'm really good at not getting good at things. I tend to think of life as a big buffet, I just try a little bit of everything; I'm no expert in anything, but I'm really good in a lot of things, and I was like, "You know what, let's try being an expert in something. Let's try being an expert in Javascript, because it's actually really fun and I really enjoy it." So I just kind of latched on and just decided to keep going with it.

**Jerod Santo:** I think there's something about the web that excites people - myself included - especially when you come from a minority or in a position where you feel like people expect you to ask for permission, or are asking why you're here, or why you deserve to belong here. You don't have to ask anybody's permission, and when you start doing websites, you just put it out there; you start writing and you just publish. \[\\00:44:04.06\\\] And sure, then you take the backlash from the publishing, or you have the problems that come alongside with that, but there's not gatekeepers, so you can deploy fast, you have the quick feedback loops, and you just have the open platform. I think that's just a beautiful thing.

**Raquel Vélez:** Yeah.

**Adam Stacoviak:** And also the fact that Javascript is in every browser. The accessibility - aside from mobile, iPhone or something like that, you can't program Javascript on an iPhone, but you can do it on iPad a bit easier with maybe some sort of cloud servers or something like that... But the accessibility to Javascript and programming with Javascript, the barrier to that entry is so low, as compared to what you said before. PHP - a little easier, or even Ruby, in theory you gotta get it right; you gotta get the right Ruby version on, and then you've gotta get all these different things in place; it usually requires Homebrew to make it a little easier, to make it the way that you would wanna develop long-term on it. So you've got all these different bumps and hurdles that you gotta get over with. Javascript, all you do is open your browser, enable a certain mode and hit command-option-9 and boom, you've got the console, the access to the source control, the source code and what not, and you're on your way.

**Raquel Vélez:** Yes, exactly. It was too easy not to get into it. \[laughter\] It was just so fun.

**Adam Stacoviak:** Yeah. On that note let's take a break. We'll come back, and we've got 20 more minutes to this show, so we'll talk deeply about robots, the book you mentioned, and any bit you could share about your experience at Npm and where you're going or what's happening there, especially around obviously what Npm is, but just how Javascript is moving forward. So we'll take that break and we'll talk about that when we come back.

**Break:** \[\\00:45:59.00\\\]

**Adam Stacoviak:** Alright, we're back from the break. This is interesting. Raquel, we've got a quote from you that says you essentially use robots as an excuse to get people excited about code and math. Is that where the motivation came for you to kind of get into that piece, get into the robots portion, combining Javascript and your Mechanical Engineering background?

**Raquel Vélez:** Yeah, definitely. Getting people excited about code and math - that's been something that I've been doing for a long time. I have this really kind of backwards way of doing education. I hate the way that traditional education currently is set up, which is like, "Let's learn addition, and then let's learn multiplication after that. Then let's start talking about algebra and then calculus" and so on. I remember sitting in high-school, looking at my calculus teacher, and he looked at me and he was like, "What's wrong, Raquel?" I just looked at him straight up and I was like, "Dude, why are we learning this? This makes no sense. \[\\00:48:04.17\\\] What is the point of all of this?" He was like, "It will all make sense soon." And it took me another five years before it all made sense. It wasn't until college that I sat down and I was like, "Oh my god, all of this makes sense now!" And I was like, "This is backwards. This is completely and totally backwards."

The way I want to teach people and what I've been doing ever since I had that epiphany is start with the cool thing first. Start with the cool thing that gets people excited. Robots are just so cool. People love robots. People love the movies, they love this idea of these little mechanical pets, or mechanical assistants or whatever, that they can boss around the way that their older siblings boss them around. There's just something really cool about robots. So when you introduce robots to people - whether they're children or adults or whatever - they're like, "Oh my god, how do I build that?" The first thing that everybody does is "I can't do that." So then I start, "Okay, what if I showed you how to do this? What if I showed you how to build one of these things?" People are like, "Oh my god, it's really that easy?" I was like, "Yeah, it really is that easy."

I like to use a carrot instead of a stick to get people excited about robots. Then what's the next thing that people ask? They're like, "If all it requires is me to start putting these things together, now what do I do?" I'm like, "What do you want it to do?" Now the control is on their part. "I want it to follow something around." "Okay, cool. So how do we get this robot to follow another person or another robot or a dot on the wall around?" Well, now we have to talk about image processing. Or we have to talk about movement, or we have to talk about basically physics and math, and now you're excited about it. Now I can say, "Okay, now here's this thing called calculus. Here's this thing called algebra. Let's get into it." Now it's no longer a chore, but a yuck that needs to be shaved. I'm very careful with that, because I think a lot of people look at chores as like, "Oh, I just don't wanna do it because there's no point, except that I understand that later I'll be happy about it." But when you're shaving a yuck, you're like "I know what the end goal is. Now I have to go backwards and get to the point where I know enough that I can move forward again." Now you're in control, it's not the teacher in control. The teacher is not in control of your learning, saying "Hey, here's how you do this or that" or whatever. Now it's you in control, saying "I'm ready to learn this thing." And I've found that to be extremely powerful, because people all over... The NodeBots movement has completely -- it's unbelievable. It is just massive right now.

It started out with just four people being like, "Alright, let's see if we can get people excited about this, because we're so excited about it", and there are NodeBots meetups all over the world. There is an international NodeBots day every July. All the NodeBots meetups have a hack day; it's like the third Saturday in July, or something like that, and all around the world everybody's hacking on NodeBots at the exact same time. And to your point, Jerod, the beauty of... A lot of people are like, "Why the hell would you use Javascript to build robots, of all the languages out there? When you build robots you use C++, or maybe you use Python..." \[\\00:51:58.20\\\]

I have been an advocate for Javascript as soon as I figured out that Javascript will be used for robots; I was like, "Forget it. Everything else - put it to the side. Let's focus on Javascript", for exactly the same reason that you said. The barrier entry to Javascript is so low, that if I can get people excited about playing with robots because Javascript is so easy to use, then I can get them excited about other things, and get them excited about engineering, and computer science, and all sorts of who knows what else. It's an absolute game changer that you're not gonna necessarily see in the next couple of weeks or the next couple of months, or even the next couple of years, but in the next couple of decades I really think people are just gonna be like, "Well, I've built a robot, so how hard can this internet thing be?"

**Jerod Santo:** Yes. I have an almost eight-year-old daughter, and we homeschool so I'm very involved in her education and what not. What's the quickest and easiest way for me to go from zero to NodeBots with her? Or zero to excited, with regard to NodeBots with her. What would be my steps to have something where she is like, "Let's do this."

**Raquel Vélez:** Alright. So I would argue, do the "Hello, world". The "Hello, world" in NodeBots is not\[unintelligible 00:53:23.08\] it's getting an LED to blink. You start out with an Arduino and you've got a little LED, and you can use Johnny-Five. Johnny-Five is a module that Rick Waldron created. Rick is on the board of jQuery. What's cool about Johnny-Five is that it feels a lot like jQuery. If you're fairly proficient with jQuery, you can easily -- even if you're not fairly proficient with jQuery; if you just understand the basic concepts of jQuery, Johnny-Five is super easy. It's like Servo.to some angle. LED.on. LED.off. It's so, so easy. So what I would recommend that you do is you start off with getting the LED to turn on, and then add a button. Add a button so that when you press the button the LED turns on, and when you let go of the button the LED turns off. And then just start playing.

The documentation and the API for Johnny-Five is so good, and it's pretty thorough, and it has so many different components that you can get and use, and all that stuff. So that's a really fun thing to do if you wanna use Johnny-Five. I'm gonna do something that's a little bit uncouth, but because your daughter is eight - I don't know if you've ever heard of Squishy Circuits...

**Jerod Santo:** No...?

**Raquel Vélez:** Okay, so there's this thing called Squishy Circuits, which is basically electronics with playdough. So you make playdough at home, and there's two different types of playdough that you create: one is with salt, and one is with sugar. What that means is one is conductive and the other one is not. And what you can do is you can actually create circuits with this playdough as like the wires between your components, and you can learn about electronics using playdough. And this is great for adults and kids, but especially if it's parents and kids working together, especially in a homeschool situation I think it's just super fun. Not only do you get to play in the kitchen and make playdough, but then you also get to play with electronics and start learning about basic E&M and all of those things. Again, it's about getting your hands dirty and playing around, and then the next thing you're gonna be doing is trying to understand "Okay, so what is the polarity of all these things? How does a capacitor work?" and those questions are things that you're gonna be excited to learn, as opposed to somebody sitting you down and being like, "Okay, so let's talk about Maxwell's equations." \[\\00:56:07.23\\\] It's just like, "Oh god, why? Why are we doing this?" \[laughs\]

**Jerod Santo:** Right. Very cool. I will definitely check out Squishy Circuits.

**Raquel Vélez:** Yes, and Johnny-Five, absolutely. Do all of it. Once you understand how electronics work, then doing the Johnny-Five stuff is even easier, and you can totally do the Johnny-Five stuff without understanding electronics. I certainly did. So yeah, it's pretty straightforward.

**Adam Stacoviak:** This approach though, to start with the exciting thing to get to this motivated state - because there's times when you learn and you're like, "I realize I have to go through the trenches for a little bit to get to the other side, and I get that", and that's good if you're starting with motivation. But if you're beginning with no motivation and someone's sort of dragging you along, which is often the case as someone beginning to learn. You're motivated by some sort of long-term goal, but the short-term is really hard, and \[unintelligible 00:57:14.21\] this goal of like, "Here's something real that you can actually see tangibly, this 'Hello, world' that isn't just a \[unintelligible 00:57:21.00\] kind of thing, it's actually blinking light, or in this case with the Squishy Circuits, that's... I'm surprised that Squishy Circuits isn't bigger. I google it and there's a bunch of stuff out there, but it seems kind of like dated, to a degree. It has information around it, but it seems like it could be organized a bit more...

**Raquel Vélez:** Yeah... Squishy Circuits came out of a university.

**Adam Stacoviak:** St. Thomas, is that it?

**Raquel Vélez:** Yeah, University of St. Thomas. The person who created it was actually one of my TAs in college, and I worship at her feat, she's just so amazing.

**Adam Stacoviak:** I mean, I watch - and Jerod does, too - Shark Tank every week, and this should be on there. This should be a business, because it's... I think kids learning, and this kind of kids' learning stuff is just... It's so hands-on and so pliable to their minds. They see, "Okay, this is green, and that conducts, and this is a no-color, and that doesn't conduct, and I get that one. I put these two together and I put this in there, the light goes on." To me that's the best learning you could do.

**Raquel Vélez:** Absolutely. So that's the interesting thing - there's so many different parts of our society that haven't figured out how to work together yet. Academia and the whole tech movement - there's so many opportunities for both to really take off, but I don't know why there's this whole, "Oh, academia, they don't know anything", and the academics are like, "Oh, they're just a bunch of 20-year-olds eating ramen while sleeping on bunk beds." There's so many opportunities for everything to coalesce, and we're just messing it up by not taking advantage of that.

So I don't know. I don't know why Squishy Circuits isn't bigger and marketed everywhere. The other thing is how do you make money off of that? You can make the recipes at home...

**Adam Stacoviak:** Well, this is not Shark Tank and I'm not Mr. Wonderful, but there's lots of areas where people don't want to make this stuff; maybe that's the interesting part, too. But just giving them the information - information is sellable; it doesn't have to be a hardened product. The book, for example, or a course, or access to ten videos that goes from zero to \[unintelligible 00:59:57.17\] lights, or something. \[\\01:00:01.09\\\] I think there's something interesting there that could be education-based. Because kids' education and education in general not so much should be a capitalistic, for-profit business, but there's certainly a lot of opportunity, because parents will pay to have their kids be educated in all sorts of unique ways. I'm sure Jerod buys books or get donated books or something for his curriculum at home, and there's some sort of monetary component that goes with it that he would totally add on to his daughter's education cycle that he would pay for. And there's Jerods all over the world.

**Jerod Santo:** Yeah, I mean there's no better investment, in my opinion. Let's ask this one last thing about robots, and then we'll talk about Npm; Raquel, we wanna respect your time and we're getting near the end here. You've been in the NodeBots community for a long time... In fact, you're kind of slowly -- not backing out of it, but you're interested in other things in 2016... But throughout your time, give us a couple of the coolest things that you've seen done with regard to NodeBots and robotics over the years.

**Raquel Vélez:** Oh my goodness... I'm not gonna answer the robotics general question, because that's just too big. But NodeBots - it's so amazing to me how far people can go with just six hours of time, starting from nothing, and building something really awesome. I've seen little robots that will know how to use a keyboard, they can type stuff out for you. Somebody built a little Wi-Fi-enabled cat laser thing. They'll be in their office in another part of town, and they will log into their home and just on their iPhone move the laser around to distract their cat in the middle of the day.

There are lots of wearables - so many fun wearable-type things. A friend of mine \[unintelligible 01:02:11.07\] makes a sash called NodeSash where if you tweet at the NodeSash, if you give it a hex color, it will queue up on the sash. So everytime that you tweet these colors, there's just like a rainbow of colors on the sash.

There are lots of robots that can do object avoidance... My whole goal as a member of the NodeBots community was to just keep pushing the edge, because a lot of people don't know where the end is, and they'll just kind of be like, "Well, this is as far as I can go, so I'm just not gonna go any further." I've built robots that had a little bit more AI in them. I had a robot that could draw. It drew an abstract piece of art. I had a robot that could scan an area and know what's in view, and all sorts of things. But probably the most impressive thing that I've seen to date is a hexapod, which is a six-legged robot that walks beautifully. It has a perfect gate, a walking pace that looks like a bug, and it's massive. I wanna say it's about two feet by two feet, a two-foot square. And it can open up, and it sounds so creepy. It is the creepiest sound because of all the servos and everything. It sounds like something out of the movies. And it's beautiful, the way that it moves around. \[\\01:04:02.22\\\] The person who built it - he's in Houston. His name has totally blanked, right just this second - of course it does; right at the moment when you need to give a shoutout. But he used Javascript animations to help program the servos, so that it would have a really fluid walk; and it is the creepiest thing... Oh, Donovan Buck - shoutout to Donovan Buck, @dtex on Twitter, for making this ridiculously creepy, but so freaking awesome robot. And he gives talks, and stuff, so I recommend seeing some of his talks to see this robot in action. It is absolutely beautiful. It was his second robot ever. The first one was the 'Hello, world'. He was like, "Alright, this Hello world is cool. Now I wanna build a hexapod", and I'm like, "Okay, you have the power, go for it!" It's really impressive.

**Adam Stacoviak:** Aside from Johnny-Five which you've mentioned already, any interesting repos out there on GitHub or elsewhere that is essential to getting started?

**Raquel Vélez:** Johnny-Five is a really good one to start with, and there are add-ons to Johnny-Five, and you can find those. I built a module called 'vektor' that does all of your matrix math. So you don't necessarily need to know how to do with linear algebra as long as you understand the basics of "This is what a vector is, and I need to rotate the vector" or whatever. I wanted to abstract out linear algebra enough so that people could just start using linear algebra and vector transformations and matrices. That was like my first Node module. I was like, "Okay, I can get into this. I have this niche that I can get into." I'm sure at this point there are better matrix modules out there, but I made it specifically for robotics. That was kind of one of my little claims to fame in the Node community. Like, "Hey, I was the first person to write a matrix module for Npm. Yay!"

**Jerod Santo:** \[unintelligible 01:06:19.17\] Matrix movies, yours will still be the best.

**Raquel Vélez:** Yes, indeed.

**Jerod Santo:** Matrix II and III really didn't help.

**Adam Stacoviak:** No, they were missing something special, and it just sort of went down from there. That's a whole different topic.

**Raquel Vélez:** I'm sorry, there's only one Matrix movie.

**Adam Stacoviak:** Oh, there is?

**Jerod Santo:** Yes, that's right.

**Adam Stacoviak:** The first...

**Raquel Vélez:** There's only one. I don't know what you're talking about. \[laughter\]

**Adam Stacoviak:** What trilogy? However, on the subject of open source and Npm, we've talked a little bit about your work there, but not deeply. We talked about you being employee number one, and Isaac reaching out to you and you thought you were an unknown, at least to him, from that perspective. But obviously this show's roots is in open source, we're called The Changelog - What's Fresh And New In Open Source. That's what our tagline has been forever, although I think our platform and this podcast and the content has kind of shifted and changed a little bit over that time, and we're probably a bit more about deeper stories than we are about what's fresh and new. But nonetheless, at Npm, give us an understanding of what your role is there and how you enjoy being able to work at a company where so much is built around open source - it was built around open source. Help us out with that.

**Raquel Vélez:** Yeah, so Npm as an acronym, which actually doesn't stand for anything - this is the one thing that will blow everybody's minds; Npm does not officially stand for Node Package Manager, it's just Npm. Yeah... I know.

**Jerod Santo:** Why? Why not?

**Raquel Vélez:** Because why should it?

**Adam Stacoviak:** Well, it did at first, but now it doesn't.

**Raquel Vélez:** No, it doesn't. If you ask, it never did. \[\\01:08:02.08\\\] If you ask Isaac, he'll be like, "No, no. It's just Npm." \[laughter\] But Npm is a package manager for Javascript. It started out as just for Node, but now people are using it for everything, from backend Node, to frontend, to robots. So it's for absolutely everything Javascript-related although, let's be real, there's CSS in Npm, there's C in Npm, there's even some Ruby and Perl in Npm at this point. So it's really just an awesome package manager. My team is the web team, and our purview is when you go to npmjs.com, we take care of everything from the design, all the way down to making sure those boxes stay up. So we are full-stack, and we care a lot about this website and making sure that it is up and useful. We have so many things on our plate... I feel so bad, because we're a really small team. Npm as a company is about 25 people, which I think surprises a lot of people. The web team itself is four - actually five people, because we include the designer. So five people trying to tackle everything there is to tackle about a website. There is always somebody upset with the state of the website, and I'm so sorry. I'm so sorry, we just cannot handle everything.

So that's our job, that's my team's job. We also have other teams at Npm. The CLI team, that's the one that everybody knows and loves, because when they do Npm install, that's their code. And of course, we have our registry team, our sales and marketing, and our support team, which is phenomenal. And our registry team, who makes sure that everything actually does stay up.

Once upon a time the Npm registry would go down pretty much at a sneeze, and now it's got like 999999% up. It's ridiculous. Our teams are so fantastic.

We love open source. So much of our code is open source. Unfortunately, as we grow, some things have to be a little bit more closed source, just because we need to make money somehow. But the benefit of that is that other people get to make closed source things with Npm as well. We introduced private packages and orgs, and we have our npm on-site, which is our enterprise solution. What that basically means is you can feel comfortable using npm for everything - not just your open source stuff, but also the things that you wanna keep just within your team or within your company, or just on your private projects that you're not ready to say 'Publish' on, because of all the possibilities that could happen when you publish code onto the internet. And I love that.

I love that the community is number one in what we do, constantly. I think a lot of people got really angry when we became a company, because they're like, "Wait, no. You can't be a company, you can't be a for-profit company. Open source is so important." And it's like, look, we could stay open source and non-profit etc, but the thing about open source is that you take advantage of the community, who wants to put in their own personal time into making your product great, and that's fantastic. But the fact of the matter is that there are some things that nobody wants to do. There's a reason why sanitation workers are paid so well, because nobody wants to do the crap work. \[\\01:12:03.08\\\] So we're getting paid to do the work that other people wouldn't necessarily step up to do with their free time, and you shouldn't have to step up with your free time to make sure that servers are up. So being able to pay people to sustainably work - that's one of the great things about npm, we really care about sustainability in terms of just our culture. At 6 PM, in our office, the lights go out. This is like a building thing, but we never stopped it from happening. The lights turn off at 6 PM, so it's time to go home. Everybody leaves the office at 6 PM, because there's no point in overworking yourself.

Our VP of engineering likes to tell everybody, she's like, "Okay, look, I want Npm to exit. I want Npm to exit big. In order for that to happen, I need everybody to be putting in their absolute best work. The only way for you to put in your absolute best work is if you sleep well every night, and eat well, and enjoy your time outside of work, so that when you're at work, you're actually doing your best work. So for the love of everything, just go home! Stop working at 6 PM! Don't get back online, we'll see you in the morning. There's nothing so horribly, awfully wrong that can't wait until the morning, unless it's like an ops thing."

**Jerod Santo:** No, the registry's up all the time.

**Raquel Vélez:** Yeah, \[unintelligible 01:13:27.27\] registry is up all the time. We have a really sensible ops rotation, I'm on it...

**Adam Stacoviak:** And that makes sense, to have a rotation for those kinds of jobs, you know?

**Raquel Vélez:** Exactly. We have a team that takes care of things when we're sleeping, so we don't get woken up in the middle of the night. I have never gotten woken up in the middle of the night. When something goes wrong, it's normally just a little box that Amazon forgot to notify us that it was shutting down, so it's like, "Alright, let's fix it." But we have such a redundant architecture that 90% of the time it's really not a big deal. So we really care about making sure that not only our employees are happy and thriving and successful, but that everybody else who's using our product is happy, and thriving, and successful. And yes, search still sucks. We know this, and we're working on it. \[laughs\] But you know, there's so many things, and there's only so much time for us to get all the things done.

**Jerod Santo:** Do you have anything npm-related that's coming down the pipeline that you can share with us? Whether it be on the open source side or even on the \[unintelligible 01:14:36.14\] side.

**Raquel Vélez:** Let's see... The website's getting a redesign, that's kind of fun. There's an npm camp coming up. It will be like a really chill conference, it's not actually camping. It will be in Oakland. You can find a tree every once in a while. Actually, I love working in Oakland. Oakland is just a fantastic place to be. I love it better than working in San Francisco by heaps and bounds, so shout out to Oakland.

And let's see, what else is coming up. You know, right now we're focusing on our products and making sure that they are the best they can be. I know the CLI is working really hard; they have such a massive, massive to-do list. There's not gonna be an npm 4 coming out any time soon - npm 3 is still the hot thing, but they do weekly releases, so make sure you're constantly upgrading your npm, just so that you have the latest and greatest. That's pretty much what I can think of.

**Adam Stacoviak:** Well, there is one topic that we have not talked about, which I'm sure if you're listening to this you've been wanting this; we have been wanting this for a very long time. \[\\01:16:06.08\\\] You rock the handle Rockbot, right?

**Raquel Vélez:** Yeah.

**Adam Stacoviak:** So I'm kind of curious... Knowing your history, knowing your path, as you've shared here on this show today - where did that name come from? Is it self-professed, has someone given you that name? Where did that come from?

**Raquel Vélez:** Yeah, so back to 2009, there was this thing called Twitter, and I wanted to be part of it, but online identity is scary, so I didn't wanna put my name on my Twitter handle. At the time - I go by Raquel all the time now, but my nickname growing up was Rocky, like the boxer or the squirrel, whichever you prefer. And the reason my nickname was Rocky was that no one could pronounce Raquel. Don't ask me how - everyone kept calling me Rachel or Rochelle, or Roquelle, and I was like "I can't handle this anymore!" I was in third grade, and Rocky was my nickname all the way through college. So I was like okay, Rocky... But Rocky si such a common name... But I also do robots. So Rocky, robots - let's just squish the two together, and I'll try being Rockbot, and that is basically forever and ever the thing.

**Adam Stacoviak:** Is it a hard handle to maintain, meaning as new networks come up, you're able to get it?

**Raquel Vélez:** I'm pretty able to get it. The only downsides are... So in freenode there's a bot named Rockbot, so I can't get it there; I have to add underscores, or something. Then there is a company called Rockbot, it's like a crowdsourced jukebox sort of thing; so when you go to a bar you can get the Rockbot app and choose a song and pay money to listen to the song in the bar. That is really hilarious, because a) they're also located in Oakland, and b) their Twitter handle is @getRockbot, because they couldn't get the @Rockbot handle because I had it first.

**Jerod Santo:** They need to hire you as their CTO. \[laughter\]

**Raquel Vélez:** Well, it's a fun story... They know somebody that I know... So my first startup living in San Francisco, they knew my boss, and they asked via my boss if I would give up my Twitter handle for them, and I was like, "No?" At that point I had like 2,000 followers and they had like 200, and I was like, "No, no, no... That's not gonna work." At this point I think very much differently, but it's super funny getting tweets every once in a while, being like, "Oh my god, Rockbot is so awesome", and they show a picture of a bar. And I'm like, "Yeah..."

**Jerod Santo:** \[unintelligible 01:19:07.13\] picture out.

**Adam Stacoviak:** Alright, last question for you Raquel, and we'll let you get back to hacking and slinging. Programming hero. We love to hear who's influenced you, and obviously your path is a zig-zag like anybody's, not a straight arrow. But who would you consider a hero for yourself? Who's been an inspiration to you in programming, in open source, that you wanna give a shout out to. It doesn't have to be one, a couple is fine, but who's your hero?

**Raquel Vélez:** Ceej, @ceejbot. C. J. Silverio is our VP of engineering at Npm. She started at Npm a week after I did, and so she and I have been on this fun journey for two years now. 90% of the things that I've learned in the last two years have come from her. \[\\01:20:04.15\\\] She is just above and beyond, holy cow amazing. I also need to give a shout out to Stubbornella, Nicole Sullivan. She's more in the CSS type of things, but she has taught me a ton about the non-coding side of things. Full disclosure, she's also my manager at the moment, but just has taught me so, so, so much about understanding a product, and understanding how to finagle your way to understanding what are the priorities, because it's so easy when you're first starting a company to be like, "Alright, I have all these billion and seven ideas. Let's execute on all of them!" And no, that's a terrible idea, don't do that. But knowing how to figure out which one of the one billion and seven... How do you pick just one to focus on, and she's kind of helping me understand that in the context of npm. So definitely massive shout outs to the two of them. I just bow at their feet. Yes, teach me everything you know. We have this joke at Npm that CeeJ and I started. Have you ever seen Heroes, the TV show?

**Adam Stacoviak:** Yeah.

**Raquel Vélez:** Do you know how Sylar would do something weird to people's brains, and everyone just assumed that he ate their brains to understand everything that they knew? So we just walk around, and I'd be like, "CeeJ, I need to pair with you, because I need to eat your brain." It's gruesome, but at the same time...

**Adam Stacoviak:** Well, it's much than pick.

**Raquel Vélez:** No, I don't wanna pick your brain, I just wanna eat it. Just give me all the knowledge that's in your brain so I can put it in my brain, so I can become all the more powerful. Yes.

**Adam Stacoviak:** So I guess not really the last question, but this is really the last question... Since you're such a wealth of knowledge, we wanna eat your brain...

**Jerod Santo:** In a nice way...

**Adam Stacoviak:** Yeah, in a nice way, of course.

**Raquel Vélez:** Oh, totally. My brain is for eating.

**Jerod Santo:** In a non-creepy way.

**Adam Stacoviak:** In a non-creepy way. What's on your radar? There's lots of open-source out there, you deeply invest with a lot of fun stuff - it's 6 PM when you take you breaks, what would you hack on that's new, fresh in open source? What's out there on your radar that if you had some time to play with it...?

**Raquel Vélez:** Yeah. Oh, man... I've done such a good job of avoiding everything for a little while. That said, I keep hearing amazing things about React. I'm just like, "Okay, I need to just build something with that", but I haven't yet. I don't know... I've just been kind of like... I think a lot of the robot stuff continues to be really fascinating to me, seeing how people are building cooler and cooler things, which aren't on the super-mathy kind of stuff.

There is somebody named Hackintosh (@hackintosh), he does some really, really, REALLY neat stuff with regards to streaming data and hacking Chromecasts to stream data that you might have gotten from BitTorrent, and just some fun things like that. That's the sort of thing that when I have time, I try to play around with that a bit more, because it's something I don't know at all. I know nothing about data streaming. I know very little about -- like, I use streams, but I don't use them the way that they use them, and that's some really, really cool stuff. \[\\01:24:00.00\\\] There's only so many things that are available via Chromecast, and I'm just like "I wanna watch this other thing!" So I think that's really fun and really cool, mad science that people do... I love seeing people do things with internet technology that no one ever thought that you should be able to do with internet technology, if that makes sense.

**Adam Stacoviak:** Yeah. Well, certainly fun things in React; we've talked a bit about that. We had Dan Abramov on not long ago. Jerod, if you've got the internet up, pull up the number for me, because I forget. But we had Dan on, and we talked about Redux...

**Jerod Santo:** 187?

**Adam Stacoviak:** 197?

**Jerod Santo:** 187.

**Adam Stacoviak:** 187 - so go to changelog.com/187 if you're listening. It will also be in the show notes for you.

**Jerod Santo:** 149 if you wanna go back to the initial React.js episode with the Facebook team.

**Adam Stacoviak:** Yeah, that was a good one. We need to get them back on, because lots has happened since then, and we could use a catch up of some sort. But React is certainly cool... What was the other one you mentioned? Hackintosh?

**Raquel Vélez:** Yeah, Hackintosh's stuff, just everything he does. He blows my mind every single time. Him and Feross, the two of them just build the coolest stuff. Like, "Whaaat? What are you doing? How... What?? Where did you come up with this idea?" \[laughter\] I love watching their talks at different conferences, because every single time it's guaranteed to just make me go, "Where do you find the time to come up with this ridiculous idea and then execute on it and then blow my mind? I don't understand!"

**Jerod Santo:** Somebody else was singing Feross' praises recently. Adam, who was it? I think it was Henrik Joreteg. I was super excited about what Feross is up to, we might have to get him on the show.

**Adam Stacoviak:** Well, I had a conversation for our ad spots with @opbeat, Thomas Watson, who runs Opbeat Node, and the Node piece to Opbeat for their application performance stuff, and he was talking about Feross and several others... But I think he was saying that Feross is sort of like independently employed, or something like that. Like somehow they're not really employed, but they're employed, this group of people.

**Jerod Santo:** It's just one guy, isn't it?

**Adam Stacoviak:** Yeah, but I'm referencing the other people Thomas mentioned, not just Feross. But this group of people are doing all the awesome stuff that Raquel's mentioned. I don't know, Raquel, is he employed somewhere? I think he just works in open source, and it's funded somehow, I don't know.

**Raquel Vélez:** He might be one of those secret Googlers, or something. There's so many of them, that...

**Adam Stacoviak:** Oh, the secret Googlers...

**Raquel Vélez:** Could be, I don't know.

**Jerod Santo:** I think we can start a conspiracy theory/rumor about Feross right now.

**Raquel Vélez:** I love starting conspiracy theories.

**Adam Stacoviak:** Well, Feross, if you happen to be listening, or someone who know Feross is listening and they know the truth, e-mail us - editors@changelog.com. We'd love to hear more. We'd like to learn the back story, and even have him on the show to dive a little deeper into what he's up to and all the neat things that he's building. Raquel, it's such a pleasure to learn more about where you came from, especially this intrepid attitude that Jerod has coined for you. I think it's such an interesting way to describe this fearless way of approaching the highest mountain sometimes, and I think you're an inspiration to people, and we look forward to hearing more about the awesome stuff you have been doing and you will do. And we mentioned off air, but you're family now, so... You're part of the Changelog family, and we'll be here to support you however we can. That is it for the show. Is there anything else you wanna mention before we go ahead and close? \[\\01:28:00.19\\\]

**Raquel Vélez:** Find a reason to smile every day. That's all. \[laughs\]

**Jerod Santo:** Nice.

**Adam Stacoviak:** That's the way to do it right there - smiles every day. Don't frown, it's bad for your face. \[laughter\] Right?

**Raquel Vélez:** Yeah, indeed. Anyway, thank you so much, this was super fun.

**Adam Stacoviak:** Yeah, thanks everyone for listening to this show. I think this is episode 200 - if it's not, I'm sad about that. Changelog.com/200. You'll find show notes there, and all the details that Raquel has mentioned on this show today. That's it, so let's say goodbye.

**Raquel Vélez:** Bye!

**Jerod Santo:** Goodbye!
