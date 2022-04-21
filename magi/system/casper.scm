(define-module (magi system casper)
  #:use-module (magi system)
  #:use-module (gnu)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)
  #:use-module (gnu services syncthing)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages gnome)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd))

(operating-system
 (inherit magi)
 (host-name "casper")
 (kernel linux)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))
 (keyboard-layout dvorak-ucw)
 (services (append (list
		    (service gnome-desktop-service-type)
		    (set-xorg-configuration
		     (xorg-configuration
		      (keyboard-layout dvorak-ucw)))
		    (service syncthing-service-type
			     (syncthing-configuration
			      (user "maya")
			      (arguments '("--no-browser" "--no-default-folder" "--log-max-size=1000")))))
		   (modify-services nonguix-desktop-services
				    (gdm-service-type config => (gdm-configuration
								 (inherit config)
								 (wayland? #t))))))
 (packages (append (list
		    xf86-input-libinput
		    (specification->package "syncthing"))
		   (operating-system-packages magi)))
 (mapped-devices
  (list (mapped-device
         (target "cryptroot")
         (type luks-device-mapping))))
 (file-systems
  (cons*
   (file-system
    (device (file-system-label "BOOT"))
    (mount-point "/boot/efi")
    (type "vfat"))
   (file-system
    (device "/dev/mapper/cryptroot")
    (mount-point "/")
    (type "btrfs")
    (dependencies mapped-devices))
   %base-file-systems)))
