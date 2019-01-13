[
  {
    title: "What does Openpilot do?",
    markdown: " Openpilot is open-source software that runs on the EON to maintain your vehicle in your lane and slows down/speeds up for the vehicle ahead on straight and mildly curvy roads.  It records the car's CAN bus data and forward-facing video to train the driving model to perform better."
  },
  {
    title: "What does Openpilot not do?",
    markdown: " Openpilot does not drive your car from point A to point B, end-to-end.  It does not allow you to take your eyes off the road, check your phone, go to sleep, or do any of the unsafe things you may see people doing in other vehicles on YouTube.  You, the driver, are responsible for taking over control at any time."
  },
  {
    title: "How does Openpilot work?",
    markdown: " It uses the EON onboard camera to read the lane lines, center the car in-between them, and follow curves.  It uses the car's CAN bus to read data from the powertrain and radar buses, makes a decision, and writes messages back to the bus.  The car's control electronics interpret those messages to accelerate/decelerate the car, and turn the steering wheel."
  },
  {
    title: "Does Openpilot see the car in front of me?",
    markdown: " Yes, Openpilot sees the radar signature of the vehicle ahead of you and maintains a distance of approximately 1.8 seconds.  On most models, your vehicle can come to a complete stop while under Openpilot control.  On many hybrid models, the car can resume moving from a complete stop without driver intervention.  See opc.ai for more details on supported models."
  },
  {
    title: "Does Openpilot detect traffic lights?",
    markdown: " No.  There is no traffic light detection at this time."
  },
  {
    title: "Does Openpilot make turns at intersections?",
    markdown: " No.  Human intervention is required at this time."
  },
  {
    title: "Does Openpilot slow down for turns or at intersections?",
    markdown: " If there is a car ahead of you, it will detect it and slow down to maintain a safe distance.  Without a vehicle ahead, it will not slow down."
  },
  {
    title: "Why can't Openpilot slow down for turns?",
    markdown: " HD Maps are needed to give Openpilot a better understanding of the local environment and how to operate within it."
  },
  {
    title: "Where/When can I get HD Maps?",
    markdown: "Comma.ai is working on open-source HD Maps, targeted by the end of 2018 or early 2019. See this Medium article: https://medium.com/@comma_ai/hd-maps-for-the-masses-9a0d582dd274 UPDATE DECEMBER 2018: Comma releases 2k19 project on GitHub: https://medium.com/@comma_ai/dataset-for-hd-maps-comma2k19-b10e8cd25a9"
  },
  {
    title: "Does Openpilot follow speed limits?",
    markdown: " No. The driver sets the desired speed. Minimum speeds are usually limited by the ECU in each car and are model-dependent."
  },
  {
    title: "Does my car work with Openpilot?",
    markdown: " Check here, with other models under development.  New cars are being added all the time, and you can participate in making your model enabled, too: https://github.com/commaai/openpilot#supported-cars and https://opc.ai"
  },
  {
    title: "I have a European car.  Why isn't it supported?",
    markdown: " Audi, BMW, Mercedes-Benz, Land Rover, and Volvo are some of the brands that use an optical communications method called FlexRay.  FlexRay adapters are neither cheap nor plentiful. If you can solve this problem, your model may become supported!"
  },
  {
    title: "Does Openpilot see people, animals, motorcycles, low slung trailers, plastic bags, baby strollers, or other objects on the road?",
    markdown: " It depends primarily on the ability of your car's radar to detect it.  However, many factors, including your radar's manufacturer, weather conditions, the size/height/orientation of the object, and the material the object is made out of, can change how well the radar sees the object.  Since these objects are generally not large flat pieces of metal facing you, results can vary.  Drive with care near these objects!"
  },
  {
    title: "Can I see how Openpilot's vision works?",
    markdown: " The vision algorithm is run under visiond, which is closed-source at this time."
  },
  {
    title: "What happens when my EON runs out of free space?",
    markdown: " Openpilot becomes disabled when EON runs out of free space (requires 15% free).  The vehicle will still function under manual control, but Openpilot cannot be re-enabled until more space is freed up. There are cron scripts that can be loaded so that the oldest drive data is removed (link)"
  },
  {
    title: "Where should I mount my EON?",
    markdown: "There are many opinions on how to mount the EON so we will suggest a couple of guides that have worked for the community…  - https://opc.ai/guides/comma-eon-mounting-calibration-7zbso7 - https://community.comma.ai/wiki/index.php/Installing_EON"
  },
  {
    title: "The car hugs the left or the right.  How do I correct this?",
    markdown: "Drive a bit more before worrying about mounting.  Sometimes you just simply need to hop on the nearest interstate and drive for 10 or so miles.  If you still are getting this hugging, you probably have some sort of strange offset on your mounting and need to follow one of the mounting guides below... - https://opc.ai/guides/comma-eon-mounting-calibration-7zbso7 - https://community.comma.ai/wiki/index.php/Installing_EON It's also possible that your vehicle needs some PID tuning on the steering if your vehicle hasn't been well tested."
  },
  {
    title: "What's the cheapest car supported by Openpilot?",
    markdown: " We hear the Corolla, and Honda Fit Touring are on the list.  You can check pricing at https://opc.ai/vehicles for more information on pricing.  Click a vehicle or lookup a vehicle, and select Trim Styles tab."
  },
  {
    title: "What's the best compact car for Openpilot?",
    markdown: " This is highly debated, but people seem to love the Toyota Prius, and the Honda Civic.  The Honda Civic is one of the most well supported vehicles.  The 2018 Honda Accord is looking really promising as well."
  },
  {
    title: "What's the best full size sedan supported by Openpilot?",
    markdown: " Your best choices are Toyota Camry and Honda Accord"
  },
  {
    title: "What's the best small SUV supported by Openpilot?",
    markdown: " Your best choices are the Honda CR-V and Toyota RAV4."
  },
  {
    title: "What's the best large SUV supported by Openpilot?",
    markdown: " The Toyota Highlander and Honda Pilot are both supported."
  },
  {
    title: "What's the best truck supported by Openpilot?",
    markdown: " Honda Ridgeline is the closest vehicle that works with Openpilot.  The rest have hydraulic steering which is incompatible.  There are many current and future vehicles that may be compatible, see https://opc.ai/lookup to check for possible compatible features."
  },
  {
    title: "What's the best electric car supported by Openpilot?",
    markdown: " Both the Tesla Model S and Chevy Volt are supported by Openpilot."
  },
  {
    title: "My keyboard is only half-displayed.  How can I get the full keyboard back to type?",
    markdown: " Reboot and it should be fixed."
  },
  {
    title: "My battery died overnight with the Panda/EON connected! How do I fix this?",
    markdown: " Your battery is probably weak, and both the Panda and EON are switched off from 12V when the car is switched off (unless you're using a comma power).  So it's more likely that you may have parasitic drain from something else in your car's electrical system such as amplifiers, radar detectors, or aftermarket head units.  [Read here](https://www.wikihow.com/Find-a-Parasitic-Battery-Drain) to learn how to check your car for parasitic drain.  If the drain current checks out at less than 50mA, have your battery tested for free at one of these major auto parts stores: Advance Auto Parts, Autozone, O'Reilly, Pep Boys."
  },
  {
    title: "On my Toyota, I'm getting a "Cruise Fault: Restart the car" message.",
    markdown: " This occurs after the EON is rebooted, or if the car is turned on without the EON connected at first.  The timing of the bus activating is faster than the Panda and Openpilot can send the appropriate CAN messages and they get out of sync.  To fix this, turn the car off for about 20 seconds and then turn the car on again.  The engine does not need to be started; simply turning the car to ACC then ON is sufficient.  For a more permanent solution, the [comma power accessory](https://comma.ai/shop/products/power/) can be installed."
  },
  {
    title: "It's raining really hard and I'm getting a Planner Solution Error.  What do I do?",
    markdown: " This is a known issue with heavy rain in versions 0.5.4 and above, and is being investigated, but there isn't an easy fix at this time.  You can try downgrading to 0.5.3 or below."
  },
  {
    title: "I'm getting odd error messages, intermittent connectivity issues, or sporadic behaviors.  How do I fix this?",
    markdown: "If this is your first attempt at running Openpilot with your hardware connected, it's most likely a connection issue.  First, ensure that the your panda is completely seated all the way on the giraffe using a rocking motion.  The panda's OBD port should slide all the way onto the giraffe and bottom out completely so that the plastic housings touch.  Don't worry, they're durable and can take the stress!  Next ensure that your giraffe is properly installed and that your DIP switches are set properly.  Unplug the giraffe and flip the switches back and forth to confirm they're fully actuated and not stuck halfway.  Then plug the giraffe back in. Finally, try rebooting the EON to see if it fixes your issue."
  },
  {
    title: "My panda is hot to the touch.  Should I be concerned?",
    markdown: " Pandas are hot blooded, and so is yours.  A hot panda is normal as long as the ABS housing is not melting."
  },
  {
    title: "What is an EON?",
    markdown: " The EON is a OnePlus 3T cell phone, cooled with a heatsink, a phone charging and fan circuit control board, and a 3D-printed case to contain it all.  It's built and tested so that you don't have to build up the hardware yourself.  It's also been designed for a wide range of operating environments for reliability."
  },
  {
    title: "Can I build my own EON?",
    markdown: " Yes, but keep in mind that you will need to build and integrate all the hardware yourself.  Your build may overheat unpredictably while driving so safe testing is critical. Start here and 3D print in ABS or another material suitable for high temps: https://github.com/commaai/eon-neos"
  },
  {
    title: "What's the best charging strategy when using EON?",
    markdown: "The EON generates a lot of heat from charging alone in addition to the duties of chffr or Openpilot.  Especially in hot climates or sunny days, it's best to use the following guidelines: 1. Always remove the EON from direct sunlight when not in use!  In hot climates temperatures can reach upwards of 140F (60C) which can damage the EON battery.  Some users have had their batteries puff up and pop off the screen.  To prevent this and maximize EON life, charge the EON overnight and upload data in an air-conditioned environment. 2. If fully charged, EON can be unplugged and turned off (this may cause post-boot cruise faults on Toyota models) 3. Install EON in car and drive, which causes the only heat to be generated to be the heat from the EON itself and less from charging heat."
  },
  {
    title: "Why isn't the EON heatsink enclosed for better convection?",
    markdown: " The EON is cooled primarily through convection and radiation.  The current design was analyzed for a compromise between the two.  Some users have tried various modifications such as applying foil to the windshield, adding or replacing fans, changing heatsinks, or 3D printing new cases to varying degrees of success.  If you find a better solution that works in all conditions, feel free to share with the Slack channel!"
  },
  {
    title: "What are appropriate EON temps?",
    markdown: " During rest times (uploading and charging) indoors, 35C to 40C is typical. The fan will run indoors when plugged in.  In the car with 70-75F cabin temperatures, most users have reported 45C temperatures.  50-55C is the upper limit that the EON should be run at for extended periods of time.  63C is the current shutoff temperature for Openpilot, in which it will no longer function until cooled down.  Try stopping in a safe location and rebooting EON to see if it resets the charging circuit."
  },
  {
    title: "What's a cheap way to cool the EON better while driving?",
    markdown: " Try the front window defroster or a device called a Noggle.  RAV4 users have made a vent deflector for the front top vent.  Make sure the onboard fan is running.  If not running, try stopping in a safe location and reboot EON to see if it resets the charging circuit."
  },
  {
    title: "Why does my EON charge intermittently?",
    markdown: "The charging circuit limits charging when temperatures go over a certain level.  This usually happens when the battery is very low and the ambient temperatures are high.  Try: 1. Disabling driver monitoring if enabled.   2. Removing SIM card to prevent cell transmissions. 3. Rebooting EON.  4. Using different USB cables.  They can also be a culprit if damaged or worn.  Other causes are under investigation."
  },
  {
    title: "Why does my EON keep turning on?",
    markdown: " The EON turns on when it detects the mini-USB cable connected. Unplug it and it will stay off."
  },
  {
    title: "Can I print my own hardware?",
    markdown: " Yes, it's recommended to print in ABS.  Don't print in PLA, it will melt in a hot car.  Official files are not available.  But Chase Higgins has built a custom case using these STL files: https://github.com/ch4se/OpenFrEON "
  },
  {
    title: "The included windshield mounts, 22 and 28 degrees, don't keep the EON perpendicular.  How can I get a different mount?",
    markdown: " Custom mounts in 22, 24, 26, 28, and 30 degrees can be printed with these STL files: https://github.com/commaai/neo/tree/master/case/eon"
  },
  {
    title: "I don't have a 3D printer.  Can I have someone else print my parts?",
    markdown: "Yes, Here's a list of places we have used and like: - Voodoo Manufacturing (https://voodoomfg.com) - Shapeways (http://www.shapeways.com) - 3D Hubs (http://www.3dhubs.com)"
  },
  {
    title: "I need to replace my self-adhesive windshield mount, where do I get replacement mounts?  Also, genuine GoPro mounts don't fit!",
    markdown: "The EON mount is slightly different and uses these mounts which can be purchased [here] (https://www.amazon.com/AFAITH-Adhesive-Mounts-GoPro-Camera/dp/B00BUD6LPY) ![Image](https://opc.ai/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBblFCIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--1a1d8ff2e2c5da458b7b6054afcdc63d07d534f8/image-1539749155275.jpg). Also, if you need additional adhesive, use 3M VHB adhesive which is designed for automotive applications."
  },
  {
    title: "My USB cable is getting worn out, and it's white and kind of obtrusive.  What's a good replacement?",
    markdown: "The cable of choice for most standard installations for a cleaner look is [this shorter black cable](https://www.amazon.com/gp/product/B074C8ZLYC). ![Image](https://opc.ai/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBbk1CIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--2a37c316e2db99da8aa8040080600991054e3f4c/image-1539749009642._SL1200_.jpg)"
  },
  {
    title: "I want a "stealth" installation that looks cleaner with less exposed cable.  What should I do?",
    markdown: " Either cut/dremel a hole out for the giraffe and panda, or buy a new trim piece.  Need the part number? Try looking inside the trim piece you pulled off to get access to the front camera.  There is almost always a part number present on the inside.   Search eBay, Amazon, or your local parts dealer for a spare part.  See the above question for USB cable suggestions."
  },
  {
    title: "How do I delete or download videos off the EON before they upload?",
    markdown: "Perform the following steps: 1. Turn off the onboard WiFi so that the uploads do not occur. 2. Turn on the WiFi hotspot on the EON. 3. On Windows, use FileZilla to SCP (Secure Copy) or delete from the following location on the EON: `/data/media/0/realdata` 4. More details here: https://www.question-defense.com/2009/04/12/how-to-scp-secure-copy-with-filezilla-on-windows-xp More information about the EON can be found here: https://opc.ai/hardware_items/eon-dashcam-devkit"
  },
  {
    title: "What does the Giraffe module do?",
    markdown: "It's an electrical device that allows the Panda to tap into the CAN bus to reads the radar data.  It uses this to give Openpilot distance information on the vehicle ahead.  It also allows the user to switch between stock ADAS and Openpilot control. More information about the different Giraffes can now be found at: https://opc.ai/hardware_items/giraffe-honda-bosch https://opc.ai/hardware_items/giraffe-honda-nidec https://opc.ai/hardware_items/giraffe-honda-nidec-flipped https://opc.ai/hardware_items/giraffe-hyundai https://opc.ai/hardware_items/giraffe-kia https://opc.ai/hardware_items/giraffe-tesla https://opc.ai/hardware_items/giraffe-toyota"
  },
  {
    title: "Can I build my own Giraffe?",
    markdown: " Yes, start here with the open source plans: https://github.com/commaai/neo/tree/master/giraffe"
  },
  {
    title: "What are the proper Giraffe settings?",
    markdown: "Start with this, courtesy of Nate Levandowski (illumiN8i): ![Image](https://opc.ai/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBcklCIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--73583befbc7d8bf567f45ebf7fc157f089ec0f5f/image-1544189111813.png)"
  },
  {
    title: "What's the difference between a white Panda and Grey Panda?",
    markdown: " White Pandas have WiFi and no GPS and are better suited for CAN hacking, and may not be supported in the future for Openpilot.  Grey Pandas have no WiFi but have precision GPS that will enable future capabilities such as HD Maps.  The EON has its own WiFi hotspot built-in, so the lack of WiFi on the Grey Panda does not prevent logging into the EON via SSH, for example."
  },
  {
    title: "What are HD maps?",
    markdown: " HD maps will open the possibilities for better localization and more human-like driving.  For example, it should allow the car to plan for upcoming intersections and curves, and steer the car at an appropriate speed."
  },
  {
    title: "My Grey Panda's antenna housing keeps detaching from the adhesive. How do I fix this?",
    markdown: "The 3D print of the Grey Panda antenna housing has coarse ridges that don't adhere well to the VHB adhesive.  Get some 200+ grit sandpaper, lay it face-up on a flat surface, and sand down the ridges until ridges are gone.  If you're thinking about using acetone, it's not recommended, and it is hard to control flatness.  Sandpaper works better. More information about the White and Grey Panda can now be found at: https://opc.ai/hardware_items/panda-white https://opc.ai/hardware_items/panda-greypanda-grey"
  },
  {
    title: "What does a comma power do?",
    markdown: " It keeps your panda powered in Toyotas to prevent the cruise fault issue.  It can drain your battery if it's weak or if you have >50mA current draw from your battery when off, so either drive more often or unplug comma power when not in use for extended periods of time."
  },
  {
    title: "What does a smays do?",
    markdown: " "
  },
  {
    title: "What does a debug board do?",
    markdown: " "
  },
  {
    title: "What's with all the animal names of comma products?",
    markdown: "The panda was originally white and black.  The giraffe originally had a long cable like a giraffe's neck."
  }
]