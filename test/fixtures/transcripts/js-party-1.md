**Mikeal Rogers:** Hey, everybody! Welcome to JS Party, where it's a party every week with Javascript. Alright, let's just dive right into it.

**Alex Sexton:** I still don't want that to be the slogan. \[laughter\] I want my voice to be heard that I think that's a dumb slogan. Move on...

**Rachel White:** I think it's dumb, but I like making Mikeal say it. \[laughter\]

**Alex Sexton:** That's fair... That's very fair.

**Mikeal Rogers:** That's really fair. Alright, I'm Mikeal Rogers...

**Alex Sexton:** I'm Alex Sexton...

**Rachel White:** And I'm Rachel White.

**Mikeal Rogers:** Alright, everybody! Let's get this party started, let's just dive right into the first topic. So Google broke the internet. I don't know why they keep pointing out flaws in the internet's security, but \[whispering\] they broke the internet again!

**Alex Sexton:** I thought they helped to disclose it, but wasn't it like some German W, some acronym...? I think it was the Germans, it's all I'm saying.

**Mikeal Rogers:** It was the Germans... Likely story. Anyway, so SHA1 hashing algorithm has been cracked. I guess in 2005 there was a paper written that said theoretically it could be cracked, but nobody had done it yet. Apparently, as of like 2010, the federal government said no government encryption can use any SHA1 algorithms, which is a pretty good indication that foreign governments have been able to crack this for a while.

**Alex Sexton:** Yeah... The only person I've seen strongly support SHA1 for the last six or seven years is Linus Torvalds in Git.

**Mikeal Rogers:** It's so annoying...

**Alex Sexton:** And not just kind of... He really was like, "You guys are all super dumb for caring about this."

**Mikeal Rogers:** I know, it's really crazy. He's still downplaying it, actually. So backing up a little bit - let's just get into what is SHA1 and what does it do. Does anybody else wanna take a crack at this, or do you want me to explain it?

**Rachel White:** I only know it from Git related stuff, so that's all...

**Mikeal Rogers:** Right, that's actually a really good way to explain it though. The way that Git uses SHA1 is kind of indicative of how everybody uses it, which is that you take a bunch of data and you say, "I want a unique identifier for this data", so you hash it. That's what Git does to every change that comes into the Git tree - it gets this hash of the data and it uses that as the identifier.

If you go to GitHub and you go to a project and then you click on Commit To and then you click on one of those Commit links, in the \[unintelligible 00:02:52.25\] you'll see this randomly-generated identifier, and that is a unique identifier for that hash. The problem is that if you could forge these - that's a very small amount of data, representing a large amount of data; theoretically, if you could reverse-engineer the algorithm, you could come up with a different data that would also hash to that same thing. People have been theoretically \[unintelligible 00:03:16.17\] and now they really can...

**Alex Sexton:** It still costs like a hundred thousand dollars. It will be cheaper, but right now, with the current algorithm... It's insane how much faster they can do it, but still, with AWS spot instances it costs around a hundred thousand dollars to break a random thing.

**Mikeal Rogers:** But how much do I have to pay Russian hackers that have a botnet? Like one Bitcoin, which is roughly twenty thousand dollars?

**Alex Sexton:** I wouldn't necessarily be worried about this... Sorry, I didn't hear that.

**Mikeal Rogers:** I was saying I'd probably need to pay one Bitcoin, which is roughly twenty thousand dollars, to get Russian hackers to break it.

**Alex Sexton:** \[\\00:04:04.14\\\] Oh yeah, for sure. The cost is still prohibitive to the point where no one's gonna troll you with this. Someone really needs to want -- there has to be a reason someone's doing this at this point. But that will only be true for like two months, or something. People will make this better instantly, and then exploit everybody across the board.

**Mikeal Rogers:** Right, and it's pretty much a given now that governments can do this at will. What that means is that if your integrity checks involve you hashing with this algorithm, now if you're just using those checks, people can just inject malware whenever they want.

**Rachel White:** I have a question. If this has been relatively not super secure for a while, what was the catalyst for people to be like, "Okay, it's finally time to stop using this thing"? Was it something that Google did that you said...?

**Alex Sexton:** Oh yeah, yesterday.

**Mikeal Rogers:** Yeah. Well, honestly, I think most people in the security community have felt since 2005 that you should stop using this. There are other algorithms that are just as good that don't have this problem. And in 2010, most reasonable companies said, "Hey, we should stop using this."

**Alex Sexton:** Browsers already don't allow -- you'll get a very big red X instead of a green lock if SHA1 is used for web security stuff. It's been well known to be very crackable by someone with a ton of money for a long time.

**Mikeal Rogers:** Yeah, but like Alex said, Linus Torvalds has just remained unimpressed by evidence, so it is still in heavy use in Git, in GitHub, and a bunch of other Linux-related stuff.

**Rachel White:** That's fine, because I'm wholly unimpressed by him, so it's okay. \[laughter\]

**Alex Sexton:** You're only gonna make him stronger.

**Mikeal Rogers:** To answer your question though, the thing that happened yesterday was that some people from Google and 'zee Germans' came out and just said, "Hey, look, we cracked it. Here's exactly how we cracked it." So it went from theoretical to "Here is an open version of this."

**Alex Sexton:** To be totally clear though, they have to try a ton of things... They were able to reduce the subset that you had to brute force to a small enough amount to be significant. But it still takes a hundred and ten years of computing time, or something like that. You had to put a lot of machines into it. But that number will slowly churn down to seconds, I'm sure.

**Mikeal Rogers:** Yeah. So if you're future-proofing, don't use SHA1.

**Alex Sexton:** Or past-proofing. If you're just proofing at all, don't use SHA1. There's SHA256, which is essentially exactly the same, with much higher entropy, so just use that instead.

**Mikeal Rogers:** I've actually become a big fan of multihash. Have you ever heard about this?

**Alex Sexton:** No.

**Mikeal Rogers:** Okay, nobody has. Juan Benet has been pushing this really hard for quite a while. He's one of the people behind IPFS, so lots of kind of distributed, peer-to-peer crypto stuff. He has really wanted to future-proof everything that he's been working on, so he started this little open source project called multi-format. What these are is essentially every time that you've gotta sit down and use a codec, or you've gotta use a particular encryption algorithm or a hashing function like this, let's just create a format that allows you to define which format you're using, so that libraries can just optionally support a bunch of different formats. And if in the future you wanna change formats, you don't break all of your clients, essentially.

**Alex Sexton:** \[\\00:08:07.13\\\] It's very similar to .mkv or .mov - all the container things for video codecs, I suppose.

**Mikeal Rogers:** Right. Although containers, oddly, do implement a bunch of features.

**Alex Sexton:** True.

**Mikeal Rogers:** This gets really ugly, actually, in codecs and containers. For multihash, for instance, there's libraries in pretty much every language ever, including a very well maintained Javascript implementation that works in the browser and in Node. So that's what I've used in a couple of projects recently. But the funny thing is that Linus is actually still just not convinced. He's basically said that the way that Git uses it is still not prone to these attacks, because they have the length of the body, and that makes this harder. We'll see how that ends up.

**Alex Sexton:** I mean, it does make it a lot harder, for what it's worth.

**Mikeal Rogers:** It does. It does make the attack a lot harder, but I do feel that rather than future-proofing or moving to just a better algorithm... He's just kind of dangling out this, like "Oh, prove me wrong, computer scientists!" \[laughs\] Which didn't work out that well for his last round of this...

**Alex Sexton:** Right... It seems silly to be like, "Well, you only half-broke it, so I'm gonna continue..." If you got through a half of my lock, I'm gonna go ahead and just change out the whole thing.

**Mikeal Rogers:** Yeah, rather than just like, "No, I'm gonna continue to put these half-locks on things."

**Alex Sexton:** Right.

**Mikeal Rogers:** This kind of reminds me that the way we think about security on the web tends to be like, "Oh, I put CloudFlare in front of it, so I'm secure now." "I added SSL, or I added TLS, so I'm secure now." But really, security is this really multi-layered thing where when you break off one layer of the onion, you need the other layers around it to still be secure, right?

**Alex Sexton:** Yeah. I think you almost can't even break off any of the layers of the onion. Security is really, really hard. It needs to be there at every layer, otherwise the other ones have no effect. I think an onion is a poor metaphor. A chain is much better - if you have a single weak link, then it doesn't matter; you can get through.

**Mikeal Rogers:** Yeah. I mean, if you look at some of the stuff people have been doing with OAuth for a while... OAuth jumps through all these hoops to basically do an extra layer of encryption. Initially, they kind of did that so that you could do OAuth over HTTP without TLS. But even when you added TLS to it, it's really nice to keep all that encryption there, and one of the things that OAuth 2.0 did was it just kind of got rid of that. It was like, "Oh, whatever... We're using TLS." But you can break TLS; we know that certain authorities have been compromised for TLS so people can give out bad certs... That's not a very good way to secure everything.

**Alex Sexton:** Sure. If you operate under the assumption that TLS is broken though, then the entire internet is broken already... The OAuth channel - if you had that extra encryption - would be broken, but then as soon as you got to that website and used it, you'd be screwed anyways if TLS is broken. So I don't think it'd be any more broken than it would already be, I guess. You're screwed, if that's the case, no matter what.

Maybe someone doesn't get your authentication credentials, but hopefully you don't reuse those anywhere else, so...

**Mikeal Rogers:** Alright. Do we have anything else to say about hashing algorithms? This is a pretty deep topic to start a Javascript show with...

**Alex Sexton:** \[\\00:11:59.24\\\] Yeah, interesting choice.

**Rachel White:** Somebody that doesn't know anything about this kind of stuff, a.k.a. me, or someone else that doesn't necessarily have to deal with the security side of the code that they write, what would be the best resource for somebody that wants to know how to actually authenticate stuff in a secure way that wouldn't anger Linus?

**Alex Sexton:** I don't know if I'm answering your question directly, but if you're building a website and you wanna make sure your website is secure, Mozilla Observatory is a really good option. It will scan your website, it will check your TLS certs (some of this is involved there) and then it will check content security policy... A bunch of different things, and it will give you a prioritized list of things to do. I would absolutely recommend putting any website you build through Mozilla Observatory to get that checklist, and score, and things like that.

**Rachel White:** Cool, that's awesome. I didn't even know about that site, so that is helpful.

**Mikeal Rogers:** I think also maybe we can call out a couple good application layer authentication schemes, as well. One of the problems with updating and getting rid of this is that people take their best practices from their common tools, and not using a secure hashing is not sending a very good message. Alex, you work for a bank - what authentications are you using over there?

**Alex Sexton:** This seems like a broad question. How do we auth our employees?

**Mikeal Rogers:** How do you auth customers? Do you actually encrypt or hash different pieces of the Stripe thing -- I hope you do... I hope that my credit card number is not just sitting there... \[laughs\]

**Alex Sexton:** Yeah, so PCI determines all of the algorithms for how you must store credit card numbers and things like that. I have a pretty good guess on what it is, but I'm not even credentialed enough to touch or look at any of that code as an early employee at Stripe. That's another one of the security precautions that PCI mandates. It is mandated by a body, but as far as all of this auth goes, I feel like maybe my security brain is coming out a little bit... The way that your password gets hacked is not hashing algorithm collisions currently.

This one's bad - I don't think too many people are using SHA1. Even if you use HMAC or SHA1 it's fine. There's even ways to make SHA1 fine, but use bcrypt to do passwords... Actually, my number one recommendation is don't implement any security stuff yourself. Use libraries that are well known and well tested. The number one rule at Stripe is don't implement your own crypto; don't invent your own crypto, because you have not thought it through correctly. That's my advice.

**Mikeal Rogers:** Agreed. I tend to rely on modules written by smarter people than me.

**Alex Sexton:** Right. The wide use of something signals far more security than a smart person, too. Someone can be smart and have a glaring hole that they singularly forgot because there's only one set of eyes on it. You can be pretty sure that the Rails auth stuff works pretty well, because every Saturday night it would be down if it didn't.

**Mikeal Rogers:** \[\\00:16:00.17\\\] Unless Linus Torvalds is maintaining that library, then...

**Alex Sexton:** Sure, sure, sure. \[laughter\] But at least it's well known. No one's being quiet about it.

**Mikeal Rogers:** Yeah. I've actually been using Sodium encryption an signing. I don't know who came up with the standard, but Mathias Buus in the Node community has gotten really into it. There's really good libraries that work both in the browser and in Node, and it's a really good, consistent, easy way to do signing encryption.

**Rachel White:** The stuff that I've seen from previous jobs that I was at where we did a lot of Node stuff was more built into CI tests, so when it would check to make sure all the tests pass, it would also check for known vulnerabilities and maybe certain NPM packages, or the way that code was written. Would that be separate to other things that people would want to integrate into their regular behavior? Or is that just another good level of authentication?

**Mikeal Rogers:** It's a good practice to -- Snyk has a service that you can plug your open source module into (I believe for free), on your GitHub PRs and stuff like that. It will check if you have any vulnerabilities, and there's obviously a proprietary version as well. That looks through your NPM tree and sees if there's any known vulnerabilities, and in fact even offers you ways to patch them and stuff like that, so it's a pretty nice tool.

But that's really just for known vulnerabilities, things we've already seen out in the wild. It doesn't really protect you against bad practices. Also, you run into this problem... Like Alex was saying, if nobody is using the module, then nobody is probably going to take the time to find these vulnerabilities early on. Using well known, well-trafficked modules will really help, as well.

I think we're pretty good there. I think that we're actually coming into the time for a break now.

**Break:** \[\\00:18:04.02\\\] to \[\\00:18:51.08\]

**Mikeal Rogers:** Alright, let's dive into this a little bit. A relatively routine new version of Node came out - 7.6. We do these releases all the time, but this one is a big deal, and people are making a big deal out of it because V8 got updated in the background. They've been doing a lot of work so that we can actually take new versions of V8 in point releases and not break the API for everybody, so that's been great. But in this release, async/await came out from under a flag, so now in a current release of Node you can do async/await.

I'm curious what you all think of this and what your views are on it? Before I get into my views...

**Alex Sexton:** I don't have a ton of opinions... I understand the two sides of this, and I feel like... I mean, I think the primary -- at least \[unintelligible 00:19:51.12\] people are calling their primary concern is performance of this, versus callbacks or Promises or whatever. I think that's silly, because a) it will get faster the next version, and b) it's such a small performance hit that who cares?

\[\\00:20:08.23\\\] It's primarily sugar; I guess there are the people who dislike sugar and there are people who like sugar. Just use whatever you want, I don't know... I dislike that this is an issue.

**Mikeal Rogers:** You're just trying to make yourself above the controversy.

**Alex Sexton:** Yeah, exactly.

**Rachel White:** Why don't you explain the controversy for us, Mikeal?

**Mikeal Rogers:** Look, there's a long, long argument against Promises. There's just a lot of people that don't like Promises. I actually don't care about Promises, I'm fully in the "do whatever you want, I don't care" camp...

**Rachel White:** I'm telling your wife.

**Mikeal Rogers:** ...but it does get annoying that people act like this is revolutionary. A lot of the articles that were written about this feature coming into Node are like, "Node finally tackles asynchronous programming." Node 0.0.2 tackled asynchronous programming. Asynchronous programming has been part of Node since day one; it's been the hardest thing for people to get over.

And callbacks... The standard callback interfaces \[unintelligible 00:21:23.14\] into something usable and really fast. I think Promises landed a while ago in V8; people have been using Promises though since early Promise standards. Bluebird is based on the Promise standard, which is the really fast one, that people really tend to like.

**Alex Sexton:** I feel like people used Promises far before it was even standard in V8, or whatever.

**Mikeal Rogers:** Right. And before it was a standard, there were all these competing standard for Promises. If you go back far enough, you just could not get two people to agree on the same Promise.

**Alex Sexton:** Well, you couldn't get jQuery to agree with the rest... \[unintelligible 00:22:03.23\] that was pretty early on, I feel like... Maybe not.

**Mikeal Rogers:** So what Alex is hinting too is this fight in CommonJS over which standard would be the Promise standard. He said A/A+ because there was also Promises/B, C and I believe D, and I don't know how many letters we got up to.

**Alex Sexton:** No one used those, though. They were just proposals.

**Mikeal Rogers:** Right. But anyway, I think \[unintelligible 00:22:32.06\] ton of work just to get Promise people to agree on the same spec, or at least get everybody to stop listening to the people who were detracting. It got like a real standard in the language, which a lot of people that don't like Promises don't like. I personally prefer not to wrap this kind of state in an object myself... But one thing that you can say about it is that the browser - if you look at all browser standards - there's just no standard way to do I/O handlers. If you look at every DOM API that has to do this, they do something slightly different, and all of them are awful. And even if you don't like Promises, most of what people do in the DOM - they do the same thing, it's just worse than Promises.

So it's nice to have a standard that going forward - if you look at the Fetch API and some of these new browser APIs - you have something unified, which is so good.

**Alex Sexton:** To be clear, Promises made it into the DOM specification, not ECMA, right?

**Mikeal Rogers:** Well, it's sort of in both. Async/await is a feature in the JS language, and it effectively yields a Promise, and it relies on that standard. You're getting into this annoying territory where we have two standards bodies working on the web platform.

**Alex Sexton:** Yeah, but the Promise object doesn't have to exist in Node (the native Promise), and it just kind of does because V8 does.

**Mikeal Rogers:** \[\\00:24:05.00\\\] Right, but there's some really low-level hooks. Now we're gonna get into some NodeJS details. There's a lot of tracing and debugging that you can do in NodeJS, especially in production systems to really get at the underlying state that's going on. There's all kinds of different methods to get at this; Node is one of the more inspectable platforms out there; there's different types of tracing that people do, and there's also this thing called AsyncWrap, which is like an async hook into the low-level event system. In order to do that, in Node there is this thing called Make callback in C++ land that wraps the callback that happens; it's just a little function.

But Promises don't have that kind of hook yet - native Promises don't have the hook yet in V8, so there's work that needs to be done to get an equivalent thing happening at the native level, which at that point actually will make it much more valuable to use native Promises, rather than something like Bluebird. But anyway... What it all comes down to is that I think people don't actually like composing Promises into a bunch of things; they get kind of annoying and messy, and then end goal has been this async/await feature, which allows you to yield out a Promise. It's a syntactic sugar on top of what people are doing now. It is one of those more important pieces of syntactic sugar that makes this far more usable than it used to be, right?

**Alex Sexton:** Yeah. It doesn't tackle a lot of the core problems people have with Promises, namely error eating, right?

**Mikeal Rogers:** Yeah.

**Alex Sexton:** But I think if you're already using Promises, async/await can be a nice update to your code style. I think for the most part it's fine - you don't have to use it, no one's forcing anyone to use it. You can almost always write a little wrapper around some dependent library that uses it to switch it back to whatever you like to use... Fibers, or whatever.

**Mikeal Rogers:** Nobody uses fibers...

**Alex Sexton:** I know, I intentionally said something that no one uses. \[laughter\] But I think it's a silly argument, just because it's sugar -- most of the time, performance on it is not going to matter materially at all, and you can choose to not use it, so... Deal with it.

**Mikeal Rogers:** Yeah, that's a really good recap. \[laughs\] I wanted more controversy. Rachel, come in and tell me how much you love Promises real quick... I'm just kidding!

**Rachel White:** That's the thing - now that I don't write a ton of production code, I can do whatever I want. Nothing makes me angry, because if it does I'll just do it a different way, so I'm pretty much indifferent about arguments in regards to code preferences. As long as it works, I'm happy with it.

**Mikeal Rogers:** We're not gonna have very good arguments on this podcast if everybody's above arguing. \[laughter\]

**Rachel White:** I mean, I'll argue, but not about this... \[laughter\]

**Alex Sexton:** The question on our chat in Slack - you can join the Changelog Slack and the JS Party channel... Seth asked "Is there any argument against async/await other than performance and "syntax sugar is bad"? Well, against async/await maybe not, because it's just sugar, but there are plenty more arguments against Promises than just performance, namely error handling - I think that's the number one complaint. Whenever you're inside of Promises, often times you're many levels deep inside \[unintelligible 00:27:46.06\] and stuff, and errors can get swallowed in a way that's very, very hard to track them down, and very hard to even get stack traces back out of them when you do catch them.

\[\\00:27:59.22\\\] You have to be very explicit about every error step along the path, and if you're not, then things just get swallowed and you don't realize that bad things are happening in your code. It may not be the number one design flaw with them, but it's certainly the number one thing people run into whenever they set up a giant Promise-based system.

**Mikeal Rogers:** Yeah, and I think also the way that it handles errors kind of conflicts with the way that not just Node handles errors, because that wouldn't be accurate - Node doesn't have a way to handle errors, but a lot of the debugging facilities and tracing facilities in Node rely on errors and exceptions kind of bubbling up to the top... So because it's swallowing them, you lose a lot of the state and you can't figure out where you're going.

So a lot of production Node systems have issues with that particular mode. That's being worked on, right? This is all really, really early days. I think that a lot of this is going to get better over time, but people that already have a big production system kind of don't like this.

There's also a style argument or a way that people like to write code argument, and this argument is as old as time. It's just an OOP versus functional programming argument. Essentially, Promises wrap up a bunch of state in this object abstraction that you can then stack and compose, and some people think that that is a bad style of writing code, compared to more functional programming style. So there's that argument out there as well.

People have different brains, and different people's brains like these different ways of writing code.

**Alex Sexton:** Sure. Seth also asked, "Is there a suggestion for avoinding the error stuff and some of these other gotchas?" I don't think there's a great one... There are good, baseline rules for how to not write Promises in a way that accidentally swallow errors, but in practice, with some of the most brilliant people, it still happens almost every time, once or twice, somewhere.

So there are other mechanisms for asynchronous coding - the baseline won't be callbacks, but then you get to what people hate about callbacks, which is 'callback hell', or whatever. I'm sure Mikeal has some things to say about 'callback hell'. I don't think he can deny that callback hell exists for some people...

But then there are other async mechanisms... Async functions are coming in the future, which is a pretty fundamentally different model. And then generators, if you know that model, or another way to yield control in certain sections, and then pop back to those -- not necessarily used in the same exact ways, but generators and async functions are kind of cool because they don't swallow errors in the same way, and they make programming asynchronously look somewhat synchronous, which is pretty cool. They also because of that can be very confusing. It's very hard to stretch your brain to say, "Oh, this one character here, this one keyword caused all this stuff to happen behind the scenes", so they can be somewhat difficult to reason about sometimes. Maybe Michael has more opinions on generators and async functions, though. Or Rachel.

**Mikeal Rogers:** Yeah, before we go too deep into this though, I just wanna point out that in the browser there's actually some new features around Promises, and for error tracking and handling, specific to Promises, that I believe actually rely on the native Promises.

**Alex Sexton:** They're for debugging the Promises, though. Your code would still swallow it, but you might be able to see it in your tooling. Does that make sense?

**Mikeal Rogers:** \[\\00:31:55.22\\\] Right, exactly. But honestly, the solution to callback hell is to write code that doesn't have callback hell, the same way that the way to not swallow errors in Promises is to write code in a way that doesn't swallow the errors, right?

**Alex Sexton:** Yeah. Not necessarily a good solution, but viable.

**Mikeal Rogers:** Yeah. I'll also say about coroutines - there's a library called Co, that's the main thing that people use on the Node side to really do a lot of the asynchronous programming using generators. It's not in super wide use generally, but it has this huge following in China. Really big. It's actually really interesting... There's this dude DeadHorse on GitHub, but he took over maintaining some of TJ Holowaychuck's modules when TJ left...

**Alex Sexton:** As we all did...

**Mikeal Rogers:** He quit for Go, as you do... He took over a lot of the Co stuff, and DeadHorse is actually a really well-known programmer in China. He helps with some of the cNODE and cnpm local stuff. He's actually a great dude, I met him when I went out to China. But because he's such a presence there, I think that he has sort of like by himself propped up the coroutine stuff, and a lot of programmers in China are actually using that. There's not as big of a Promise following there, it's much more around the Co stuff. It's really interesting... It's one of the few divergences in preferences that I know that are actually geographical.

**Alex Sexton:** I actually only use the async module.

**Mikeal Rogers:** That's kind of not maintained anymore either.

**Alex Sexton:** That was not true... But back in the day, that was somewhat revolutionary. I think some of people's love for Promises came out of the bridge between Promises and callbacks that async was. It was like this weird middle ground where you didn't have to count the number of different things that had finished, or introduce multiple layers of callbacks in a row. You could kind of use the async module to flatten some of those things. But it definitely wasn't, by any means, a standard, or even internally consistent in how it worked. It was nice from a community growth standpoint, it was a stepping stone.

**Mikeal Rogers:** I think in the server space and in the frontend space, if you get popular enough somebody will make a Promise version of your thing and there will be like a following around that... Like, there's definitely that pull request. I'm actually curious, Rachel, if you see this in the hardware space at all, if there's as much of a Promise following in NodeBots and what not.

**Rachel White:** I honestly couldn't tell you, because I live in such a siloed thing. A lot of the NodeBot stuff is a very single-usage thing, so you'll have like one sensor being controlled by some other input. There's not a lot of need for a ton of Promises or stuff that you would need to have something special. You just don't run into the same kind of problems that you run into when you're writing things for the web, which is probably why I like hardware so much.

**Alex Sexton:** What about sequential actions? Like, you want some servo to do this, then this, then this, then this.

**Rachel White:** Oh, okay... Well, the thing that you run into the most then is when you're trying to run stuff on serial port; when you're getting data from multiple places at once and sometimes this stuff that you're waiting to happen from your sensor over Wi-Fi isn't going to happen as quickly or in sync as the stuff coming over your serial port cord, so... It is sort of an issue, but not that much. I, at least, haven't run into it that often. Plus, whenever I have to deal with a bunch of really intense -- it usually happens whenever you have to rewrite more custom C to handle new kinds of chips, and then have the C work with your Johnny-Five stuff on an Arduino or a Tessel.

**Mikeal Rogers:** \[\\00:36:21.27\\\] It's all like really low-level callback stuff, right? You don't get a lot of high-level proposition at that layer...

**Rachel White:** Yeah... I'm trying to think of anything that I've done recently that has been what I would refer to as callback hell, and it probably would be some Node application that I utilized graphics magic with. I'm actually interested in going in and trying out the new Node version with that kind of stuff. I think it might be really helpful for people that do a lot of procedural art-based stuff on the web, actually.

**Mikeal Rogers:** Also, there's these performance arguments right now, and honestly, even though I'm not a huge Promise advocate, I think most of the performance arguments are really dumb. But in hardware, it actually makes sense. The reason why I think that the performance arguments are stupid is that you're talking about 0.02 milliseconds I think is like the largest difference between Bluebird and Promises and native Promises. And if you're talking to the network or the file system, that's really not a thing. Your websocket delay to local host is roughly like a 3 millisecond roundtrip time, so it's just not ever gonna be noticeable.

But with a serial port, you're talking to the hardware there. It is asynchronous, but it is really, really fast, so you could actually see some of the performance stuff stack up there, and you might actually start to care.

**Rachel White:** I don't care about much, but we'll see. \[laughter\]

**Mikeal Rogers:** How fast can I AI this cat photo to blink this LED to...

**Rachel White:** Okay, listen, don't... Don't...

**Alex Sexton:** Don't pigeonhole me...

**Rachel White:** Yes, exactly. I like other animals. \[laughter\]

**Mikeal Rogers:** I thought you were gonna say, "I do more than just cat images."

**Rachel White:** I wish I did.

**Mikeal Rogers:** \[laughs\] Oh, that's awesome.

**Rachel White:** You know, I enjoy pigeons and raccoons and other various other animals that love garbage... \[laughter\]

**Alex Sexton:** We should have Isaac on, so you guys could discuss...

**Rachel White:** Oh, I've already discussed raccoons with Isaac...

**Alex Sexton:** I know, I just want that to be like a live voice thing.

**Rachel White:** I don't know if I ever want to have that conversation again.

**Alex Sexton:** Yeah, I made a mistake then.

**Rachel White:** For anyone that's wondering, Isaac from NPM - if you ever see them, talk to them about how much they love raccoons. \[laughter\]

**Alex Sexton:** They don't.

**Mikeal Rogers:** \[laughs\] And on that note, we're about ready for another break. When we come back, we'll talk a little bit about the featured project of the week.

**Break:** \[\\00:39:05.24\\\] to \[\\00:39:54.22\]

**Mikeal Rogers:** And we are back. We're gonna get into the featured project of the week, AR.js. Rachel's particularly stoked about this one, so I'm gonna let you take this over.

**Alex Sexton:** It's about assault rifles?

**Rachel White:** No, no...

**Mikeal Rogers:** That's version 15.

**Alex Sexton:** AR.js v15...

**Rachel White:** Okay, so AR.js is this really awesome library that you can use now that is augmented reality for the web using AR toolkit. It's built of a couple other different technologies. It's using three.js, it's using Mozzila's A-Frame, which is -- if you haven't messed around with A-Frame, what it does is it allows you to do web WebGL, WebVR in the browser, so you can either view things in the browser with a 3D appearance, or if you have a Google Cardboard or any other kind of virtual reality headset that phones go into - it allows you to actually see the 3D object that you have developed in virtual reality, with your phone.

What AR.js does is it blends all of these things together and allows you to use digital markers. They're using hero markers, which are these squares that have...

**Alex Sexton:** Little Greek burritos...

**Rachel White:** No! \[laughs\] They're like QR code. Basically, any kind of digital marker is just using image processing with nearest neighbor type of math-y things... I'm great at explaining things technically. Basically, what AR.js does is -- unfortunately, if you have an iOS phone it doesn't work, so I can't even test it, which bums me out... But if you have an Android phone, you can set it up so that you have your 3D environment that you've crafted with A-Frame, and A-Frame is built on top of three.js, because it allows for the 3D objects in the browser.

Then it uses the AR toolkit, which was originally elaborated in C, and they've made it work with Javascript. It does that nearest neighbor processing of the hero marker, and it assigns your 3D object so that when you use your phone in a WebGL supported browser and you point it at the marker, either on a computer screen or a piece of paper that's printed out, whatever 3D object you've assigned to that marker in your code will appear on the phone or the device that you're viewing it through as a hologram type thing.

It's really cool. A-Frame is really accessible for people that are just starting out in Javascript. Their documentation is amazing, and pretty much what this AR.js library does is it allows you to take -- they basically took all of the difficult steps out of the equation. Everything is built together for you, the documentation on it is pretty good; it says that it runs at 60 FPS on a Nexus 6, which is pretty impressive, and there's a lot of examples of three.js things that you can do with it, so I'm excited to see what people make with it, because I'm very interested in any kind of augmented reality, virtual reality, mixed reality situation that we can do with Javascript. It's super exciting.

**Alex Sexton:** This is only a slight side check... So it runs at 60 FPS, and if you look at the pictures of it, it's like this blob that sits on a piece of paper, and you can look around and the blob stays on the piece of paper, which is pretty nifty. You can move it and animate it and things like that; you can spin it on the piece of paper while you look around. That runs at 60 FPS, and that's pretty verifiable on the phone. But I can't get a div to animate from 200-pixels-high to 500-pixels-high at 60 FPS. I can't get my web page to scroll at 60 FPS by default half the time.

**Mikeal Rogers:** \[\\00:44:18.15\\\] It's because you're not using WebGL! \[laughs\]

**Alex Sexton:** I know... I'm just always so amazed that the difference -- everybody is almost hitting 60 FPS, but the place where we're starting out is always so different... It always blows my mind when these things work quickly, that's all I wanted to say.

**Rachel White:** I mean, obviously that just means that the future of web is that it's all gonna be holograms...

**Alex Sexton:** I'll buy it. \[laughter\]

**Rachel White:** Yeah... I'm into it. I actually would be really interested in finding out -- I know that there's a device called the Leap Motion. It's a USB device that lets you essentially use your hand -- I think it's like two cameras, so it's essentially scanning the space above the Leap Motion, and when you put your hand in front of it, you get a 3D model. It's used a lot with Unity and gaming type stuff like that, but I know that there is a way to use it with WebGL, so now I'm curious if I'm able to use a Leap Motion with this augmented reality application to not only be able view holographic things through a device, but if I could couple it with another thing and try and move things around.

I'm just thinking of all the really weird and awesome stuff that people can build with this. This is the stuff that I get excited about.

**Alex Sexton:** Yes, and thanks in advance to Leap Motion for sponsoring the JS Party podcast, and also thanks in advance to the next company I'll give free advertising to, the Myo armband I backed on Kickstarter a long time ago. It's not quite positional, so it might not know exactly where your hand is (I feel like you could do that with a marker), but then it essentially can give you data about your exact hand position. It's an armband that goes kind of like next to your elbow, pretty far back, and it just reads the tensions in your different tendons, to know that your hand is doing a motion like a pull or a push or a squeeze or any of those different things...

**Rachel White:** Yeah, I remember seeing that.

**Alex Sexton:** I've actually given a few talks where you hook up the next slide and previous slide, and it's just like swipes in the air or behind your back, and then you can start animations or different things like that with squeezes... There's a whole set of default things for Keynote and stuff. It's pretty nifty, though I find that sometimes you have false positives and it'd just slide whenever you're gesturing wildly.

You could just put a marker on your hand to know a position; you can get an RFID tattoo -- or not an RFID, a QR code. Rachel, you have the RFID baked into your hand, right?

**Rachel White:** Yeah, I have an RFID chip in my hand.

**Alex Sexton:** Yeah, that's in solidarity with your pets.

**Rachel White:** Yeah, that's how much I love cats. I'm really dedicated.

**Alex Sexton:** But I think you could do some really cool stuff with not just the position of your hand, but the motion of your fingers and stuff like that, like picking it up versus pushing it, versus all that stuff. Maybe a Leap Motion plus a Myo... You just mix them all together and get a drone in there somehow...

**Rachel White:** Yeah, every single kind of crowdfunded device - put them all together and see what you can get.

**Mikeal Rogers:** This is a really cool project. This reminds me... When they first used M scripting to compile down Doom and these 3D games, when they were first doing 3D standards in the browser, and those demos that nobody really ever used were what ended up pushing the web's implementation of WebGL forward.

**Alex Sexton:** \[\\00:48:06.04\\\] Yeah, I mean... Brendan tore the conference circuit for like three years on those demos.

**Mikeal Rogers:** And he's so bad at playing it, too... It was so funny.

**Alex Sexton:** He eventually - after dying so quickly, so fast, so many times in front of 500 people - hacked the parameters to the game to where he can't die; he plays in god mode now when he does the demo.

**Rachel White:** Are you talking about the Sentry Chicken talk?

**Alex Sexton:** Yeah... The same version of that talk has different games.

**Rachel White:** Okay.

**Alex Sexton:** Actually, one thing mashup I'd love to see with this - just spitballing here - is some sort of like... If you use a piece of paper, and then you're able to kind of draw shapes, and then press some button on your keyboard and then it AR-ifies it to where you can pick up the shape... Does that make sense? It's essentially like the style in the super futuristic movies - I feel like we're almost there, where you can draw something and then manipulate it in 3D space.

**Rachel White:** Well, there is something that exists like that. Not in the Javascript world, but there is an application called Vuforia, that allows you to create those augmented experiences where you can interact with this. So maybe somebody should do that.

**Alex Sexton:** Yeah, I look forward to one of our listeners from this week presenting that on the show next week. It just takes one week, right?

**Mikeal Rogers:** Yeah, yeah. \[laughs\] So have you all done any WebGL programming at all, or played around with any of the raw stuff?

**Rachel White:** Yeah, I have. I have a bit. I'm learning A-Frame, I'm messing around with a bunch of other various three.js stuff, and I've done some WebGL video game things. This is something that I'm super interested in. Plus, it's happening so fast... People are making cool stuff with this, and I find that the people that are actively developing interactive things for WebGL-based art are not software engineers for their day jobs, they're just multi-faceted technologists and artists that were like, "Oh, this is cool. I wanna make cool stuff for this." That's really awesome.

**Alex Sexton:** I haven't done a ton of WebGL stuff. A little bit for some of the Stripe \[unintelligible 00:50:40.17\], but I have met Mr. Dube, which I feel like it's pretty much the same thing.

**Mikeal Rogers:** Okay, there you go. I've tried to use three.js and I really couldn't get my head into it. It's one of those libraries that's just so massive. I could take a demo and kind of hack it up, but I couldn't really get my head around it.

**Rachel White:** So wait... Let me get this straight. You'll build an oven to bake your own bread, but you didn't wanna do a deep dive into three.js?

**Mikeal Rogers:** Well no, it's because to get at the low-level constructs that I actually wanna figure our in order to understand how everything is built, there was too much code in the way. What I eventually ended up finding though is Mikola Lysenko and Substack live on the big island in Hawaii now next to a volcano, and they hack on this thing called Regl.

**Rachel White:** Wait, wait...

**Alex Sexton:** You've gotta skip over that kind of thing...

**Rachel White:** Wait, Substack lives on an island in Hawaii now?

**Mikeal Rogers:** Yeah, Substack and Mikola and Marino all moved to the big island in Hawaii, because it's cheap and because coconuts have 1,200 calories in them.

**Rachel White:** Okay...

**Mikeal Rogers:** \[laughs\] Yeah, it's amazing.

**Alex Sexton:** You have to eat the skin in order to get all 1,200.

**Mikeal Rogers:** \[\\00:51:59.16\\\] \[laughs\] No, but they are building this thing called Regl. Essentially, it's various substacks modules philosophy, and Mikola is just this amazing math dude, doing all these kinds of crazy algorithms. It essentially gives you WebGL, but then adds a bunch of features and kind of modules, and you can plug in different algorithms and stuff really easily into it. But the most amazing thing about it is when you get an error in your WebGL code, you actually get line numbers out of the debugger that gives you your line number in your crazy abstract thing from Regl.

It's really well put together, and they've done a really amazing job with the tooling and the debugging side of it. I was actually able to build much cooler, quicker things with Regl than I could with three.js. Even though there's far less big demos and stuff written with it yet, I did find it easier to just kind of pick up and learn.

Anyway, I think we're nearly good. We're gonna do picks now... It's time for picks. I hope you all picked something that you like that you can link to, or you can just pull one of the many things that you've already mentioned in the podcast so far.

I'll go back and I'll just pick Regl, because it's an awesome library; I think they did a great job, and I love those guys. I hope they don't die in a volcano eruption. Oh, and I'll plug bits.coop. Mikola and Substack do consulting for any 3D programming stuff that you need - or really just any programming that you need. They're pretty amazing, and they're available through bits.coop. They're trying to do a cooperative anarco-socialist style thing for a consulting business. Check that out.

**Alex Sexton:** My pick will be Observatory from Mozilla, which is the security checker that I mentioned before. If you have a website and you're interested in finding the security properties of that website and what you might wanna do to increase them, such as get rid of your SHA1 certs, then check out Observatory.mozilla.org.

**Rachel White:** My pick is actually a talk, and it's Mariko Kosaka's talk on How Computers Read Pixels. It's really interesting and has great diagrams if you're ever wondering how image processing works, which is a foundation for a ton of augmented and mixed reality stuff with WebGL. It kind of helps you understand on a more fundamental level what is happening when you're looking at these AR markers.

**Mikeal Rogers:** Mariko's talks are always so good. She really dives into these concepts that everybody takes for granted, and really learns them and explains them in a really amazing way.

**Rachel White:** I know. I've told her that I really appreciate how she doesn't just explain how something's working so that it's accessible to everyone, but she also tells the journey of what lead her to want to even do that in the first place, and the struggles that she had while making it, and then the successes. Those are my favorite kinds of talks. I'm gonna try for the picks maybe every other week, between maybe a library or a project that's cool, and then other talks that I think are really great.

**Mikeal Rogers:** Of course, you can find links to all this stuff in the show notes. That's it for this week... We'll of course be back next week. Rate us on iTunes, because that's the thing that people say at the end of podcasts, so you should probably do that...

**Alex Sexton:** Subscribe and rate!

**Rachel White:** And be nice!

**Mikeal Rogers:** Subscribe, be nice... And yeah, check us out at JsParty.fm.
