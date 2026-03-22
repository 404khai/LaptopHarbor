
import json
import random
import re

brands = ["Dell", "HP", "Redmagic", "Lenovo", "Asus", "Acer", "Apple", "Logitech", "Razer", "Corsair", "HyperX", "MSI"]

USD_TO_NGN = 1352.0

laptop_models = [
    {
        "model": "Macbook Neo",
        "brand": "Apple",
        "images": [
            "https://www.apple.com/v/macbook-neo/a/images/overview/product-stories/new-to-mac/ntm_hero_endframe__4u6qzi7yehe6_large.jpg",
            "https://9to5mac.com/wp-content/uploads/sites/6/2026/03/macbook-neo-2.webp?w=1600",
            "https://www.apple.com/newsroom/images/2026/03/say-hello-to-macbook-neo/article/Apple-MacBook-Neo-citrus-260304_big.jpg.large.jpg",
            "https://media.wired.com/photos/69accd0ec61ab22ac1bc4d8a/master/w_1600%2Cc_limit/MacBook-neo-03(1).png",
        ],
    },
    {
        "model": "XPS 15",
        "brand": "Dell",
        "images": [
            "https://latalata.ng/image/cache/catalog/Product%20images/Kaybec/laptop/20--700x700.jpg",
            "https://www.techadvisor.com/wp-content/uploads/2022/06/dell-xps-15-review.jpg?quality=50&strip=all",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/02/5531914/1.jpg?7277",
            "https://i5.walmartimages.com/asr/a140bef6-1c76-4180-987d-8cfc6732cf11.b0e89d3e656d607d3d8580972d9ab68c.jpeg?odnHeight=768&odnWidth=768&odnBg=FFFFFF",
        ],
    },
    {
        "model": "Spectre x360",
        "brand": "HP",
        "images": [
            "https://media.wired.com/photos/59e94f9234ce5c0e0a752e11/master/w_1600%2Cc_limit/SphinxInline.jpg",
            "https://pacific.com.ng/wp-content/uploads/2025/08/hp-spectre-14-x360-ultra-7.jpg",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/00/1808814/4.jpg?0931",
            "https://dreamworksdirect.com/cdn/shop/files/6532928cv1d.avif?v=1755619109",
        ],
    },
    {
        "model": "Omen Max 16",
        "brand": "HP",
        "images": [
            "https://pcplaceng.com/laxgts/2025/10/image-2025-10-13T104359.962.webp",
            "https://hp.widen.net/content/a4qca5j1ge/png/a4qca5j1ge.png?w=800&h=600&dpi=72&color=ffffff00",
            "https://m.media-amazon.com/images/I/816JXR4tzWL.jpg",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/51/3742914/3.jpg?7260",
        ],
    },
    {
        "model": "ThinkPad X1 Carbon",
        "brand": "Lenovo",
        "images": [
            "https://pacific.com.ng/wp-content/uploads/2022/09/Lenovo-thinkpad-x1-carbon.webp",
            "https://image-cdn.ubuy.com/lenovo-thinkpad-x1-carbon-gen-11-intel/400_400_100/694842b02e3289065a0f259d.jpg",
            "https://image-cdn.ubuy.com/lenovo-thinkpad-x1-carbon-gen-11-intel/400_400_100/694842b02e3289065a0f258b.jpg",
            "https://p3-ofp.static.pub//fes/cms/2024/07/05/umcrxcnsm2br1itju6gvundeb9s6tf364734.png",
        ],
    },
    {
        "model": "Yoga 9i",
        "brand": "Lenovo",
        "images": [
            "https://i5.walmartimages.com/asr/11a72c12-a798-4029-98a5-2bd8dd25837b.fae5315625c1a8f68a67a61eb40a73e5.jpeg?odnHeight=768&odnWidth=768&odnBg=FFFFFF",
            "https://cdn.mos.cms.futurecdn.net/iu5vVaCiUXvEchTicTL6hA.jpg",
            "https://p1-ofp.static.pub/fes/cms/2022/12/07/l64k7j84ev4j8cs5nax600vwvxfu7p875096.png",
            "https://www.techspot.com/images/products/2021/laptops/org/2021-07-09-product-2.jpg",
        ],
    },
    {
        "model": "MacBook Air M2",
        "brand": "Apple",
        "images": [
            "https://http2.mlstatic.com/D_NQ_NP_829649-MLA99482022282_112025-O.webp",
            "https://i.ebayimg.com/images/g/mAkAAeSwL9lpBNTn/s-l1600.webp",
            "https://www.apple.com/newsroom/images/product/mac/standard/Apple-WWDC22-MacBook-Air-lp-220606.jpg.og.jpg?202602252002",
            "https://techcrunch.com/wp-content/uploads/2022/07/CMC_1580.jpg",
        ],
    },
    {
        "model": "MacBook M4 Pro",
        "brand": "Apple",
        "images": [
            "https://i.ebayimg.com/images/g/1iwAAOSwmnBlVbq9/s-l1600.webp",
            "https://i.ebayimg.com/images/g/SY0AAOSw37RlVbrA/s-l1600.webp",
            "https://hips.hearstapps.com/hmg-prod/images/apple-m4-macbook-pro-lead-672b861685fd0.jpg?crop=0.6666666666666666xw:1xh;center,top&resize=1200:*",
            "https://techcrunch.com/wp-content/uploads/2024/11/CMC_8144.jpg",
        ],
    },
    {
        "model": "Titan 16 Pro",
        "brand": "Redmagic",
        "images": [
            "https://techxreviews.com/wp-content/uploads/2025/11/RedMagic-Titan-16-Pro-2026.mp4_snapshot_08.32.jpg",
            "https://fdn.gsmarena.com/imgroot/news/24/10/red-magic-titan-16-pro-review/inline/-1200w5/gsmarena_011.jpg",
            "https://fdn.gsmarena.com/imgroot/news/24/10/red-magic-titan-16-pro-review/inline/-1200w5/gsmarena_008.jpg",
            "https://fdn.gsmarena.com/imgroot/news/24/10/red-magic-titan-16-pro-review/inline/-1200w5/gsmarena_010.jpg",
        ],
    },
    {
        "model": "ZenBook 14",
        "brand": "Asus",
        "images": [
            "https://www.myfixguide.com/wp-content/uploads/2023/12/ASUS-Zenbook-14-OLED-Body.jpg",
            "https://i.ebayimg.com/images/g/DYoAAeSwV1lpjJ~M/s-l1600.webp",
            "https://i.ebayimg.com/images/g/CE8AAeSwdzRpjJ~M/s-l1600.webp",
            "https://i.ebayimg.com/images/g/NhQAAeSw371pjJ~M/s-l1600.webp",
        ],
    },
    {
        "model": "ROG Zephyrus G14",
        "brand": "Asus",
        "images": [
            "https://www.myfixguide.com/wp-content/uploads/2024/02/ASUS-ROG-Zephyrus-G14-2024-4.png",
            "https://i.ebayimg.com/images/g/4X4AAeSwzLlpoLv~/s-l1600.webp",
            "https://i.ebayimg.com/images/g/84AAAeSwqXlpoLv~/s-l1600.webp",
            "https://i.ebayimg.com/images/g/akUAAeSwF95poLv~/s-l1600.webp",
        ],
    },
    {
        "model": "Blade 16",
        "brand": "Razer",
        "images": [
            "https://m.media-amazon.com/images/I/81sNAS5lIyL.jpg",
            "https://thetechdealz.com/wp-content/uploads/2025/04/Razer1.jpg",
            "https://img.overclockers.co.uk/images/LT-03E-RA/6236090f9866ab8936fbffdbbcfb71c7.jpg",
            "https://b2c-contenthub.com/wp-content/uploads/2023/04/Razer-Blade-16-keyboard.jpg?quality=50&strip=all&w=1200",
            
        ],
    },
    {
        "model": "Alienware M16 R2",
        "brand": "Dell",
        "images": [
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/07/1762914/4.jpg?1039",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/07/1762914/2.jpg?1039",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/07/1762914/3.jpg?1039",
            "https://cdn.mos.cms.futurecdn.net/ht4C4qRVGg5NnwQm3WLsrK.jpg",
            
        ],
    },
    {
        "model": "Predator Helios 16",
        "brand": "Acer",
        "images": [
            "https://cdn.assets.prezly.com/157fb284-7b4c-4bdb-bcaf-fbabc317b639/PREDATOR-HELIOS-NEO-16-PHN16-72-02.jpg",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/39/8041914/3.jpg?0804",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/39/8041914/2.jpg?0804",
            "https://microless.com/cdn/products/4679201588f65ddb18a82503b988e760-hi.jpg",
        ],
    },
    {
        "model": "Stealth 15M",
        "brand": "MSI",
        "images": [
            "https://m.media-amazon.com/images/I/71p3Ygm14wL._AC_SL1500_.jpg",
            "https://storage-asset.msi.com/global/picture/product/product_1642749355beafee883c67bc01eefbb5e74751799b.webp",
            "https://www.scan.co.uk/images/infopages/msi_laptop/30-series/Stealth_15M/topimage.png",
            "https://storage-asset.msi.com/global/picture/product/product_1647299935ac38d9de46efa12c710a7e56c5da2a60.webp",
            
        ],
    },
]

mouse_models = [
    {
        "model": "MX Master 3S",
        "brand": "Logitech",
        "images": [
            "https://resource.logitech.com/c_fill,q_auto,f_auto,dpr_1.0/d_transparent.gif/content/dam/logitech/en/products/mice/mx-master-3s/migration-assets-for-delorean-2025/gallery/mx-master-3s-top-view-graphite.png",
            "https://i.ebayimg.com/images/g/TcAAAeSwrMdpRGKR/s-l1600.webp",
            "https://www-konga-com-res.cloudinary.com/image/upload/f_auto,fl_lossy,dpr_auto,q_auto,w_1920/media/catalog/product/G/T/196037_1680388727.jpg",
            "https://www-konga-com-res.cloudinary.com/image/upload/f_auto,fl_lossy,dpr_auto,q_auto,w_1920/media/catalog/product/T/J/196037_1680388689.jpg",
        ],
    },
    {
        "model": "G502 Hero",
        "brand": "Logitech",
        "images": [
            "https://i.ebayimg.com/images/g/FS4AAOSwi6Fmf8y7/s-l1600.webp",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/33/0548852/1.jpg?8470",
            "https://i.ebayimg.com/images/g/Q8YAAOSwlLFmf8yD/s-l1600.webp",
            "https://i.ebayimg.com/images/g/3poAAOSwuRpmf8yD/s-l1600.webp",
        ],
    },
    {
        "model": "DeathAdder V3",
        "brand": "Razer",
        "images": [
            "https://www.pbtech.com/pacific/imgprod/M/S/MSERAZ87084__1.jpg",
            "https://cdn.mos.cms.futurecdn.net/EN57bgFd7ucLprNmfJDgQk.jpeg",
            "https://cdn.mos.cms.futurecdn.net/KnUeL8LPp6fA2jJsVQLqgm.jpeg",
            "https://tpucdn.com/review/razer-deathadder-v3-pro/images/title.jpg", 
        ],
    },
    {
        "model": "Basilisk V3",
        "brand": "Razer",
        "images": [
            "https://i.ebayimg.com/images/g/Xz0AAOSwJwhiG3ka/s-l1600.webp",
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnUJMrz5tqeb17hqk2ApipQTtl3zfwIdQZWQ&s",
            "https://i.rtings.com/assets/products/HlSiCAs0/razer-basilisk-v3/design-medium.jpg?format=auto",
            "https://m.media-amazon.com/images/S/aplus-media-library-service-media/7b915a33-f30a-44f0-b6c4-8792615b429a.__CR0,0,600,450_PT0_SX600_V1___.jpg",
            
        ],
    },
    {
        "model": "Dark Core RGB",
        "brand": "Corsair",
        "images": [
            "https://assets.corsair.com/image/upload/c_pad,q_auto,h_1024,w_1024,f_auto/products/Gaming-Mice/CH-9315311-NA/Gallery/DARK_CORE_RGB_SE_01.webp",
            "https://m.media-amazon.com/images/I/61Q8UQrNpxL._AC_SL1500_.jpg",
            "https://i.rtings.com/assets/products/r3YpGetx/corsair-dark-core-rgb-pro/design-medium.jpg?format=auto",
            "https://assets.corsair.com/image/upload/f_auto,q_auto/content/ch-9315211-na-dark-core-rgb-04.png",
        ],
    },
    {
        "model": "Pulsefire Haste",
        "brand": "HyperX",
        "images": [
            "https://row.hyperx.com/cdn/shop/files/hyperx_pulsefire_haste_wireless_black_1_top_down.jpg?v=1700189384",
            "https://m.media-amazon.com/images/I/61fHMXV+ANL._AC_UF1000,1000_QL80_.jpg",
            "https://m.media-amazon.com/images/I/61NxH1E1EDL._AC_SL1500_.jpg",
            "https://m.media-amazon.com/images/I/61Z0QVvbFHL._AC_SL1500_.jpg",
        ],
    },
    {
        "model": "Magic Mouse 2",
        "brand": "Apple",
        "images": [

            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/17/915098/1.jpg?6166",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/17/915098/2.jpg?6166",
            "https://i.ebayimg.com/images/g/B-0AAeSwMixpZ0WK/s-l1600.webp",
            "https://i.ebayimg.com/images/g/zLoAAOSwwclmbhXh/s-l1200.jpg",
        
            
        ],
    },
    {
        "model": "Viper Ultimate",
        "brand": "Razer",
        "images": [
            "https://m.media-amazon.com/images/I/61M2OwtouxL.jpg",
            "https://assets.razerzone.com/eeimages/support/products/1577/ee_photo.png",
            "https://scdn.comfy.ua/89fc351a-22e7-41ee-8321-f8a9356ca351/https://cdn.comfy.ua/media/review/main/IMG_4808.jpeg/f_auto",
            "https://preview.redd.it/razer-viper-ultimate-users-how-is-your-experience-with-the-v0-umz9ggtjo7vd1.png?width=1536&format=png&auto=webp&s=54e3593d6e5f6b3b3cff39108d09fa2e5a910d2f",
        ],
    },
]

keyboard_models = [
    {
        "model": "MX Keys",
        "brand": "Logitech",
        "images": [
            "https://media.stockinthechannel.com/pic/60qDoO-C3ka2PVvCRStM8A.c-r.jpg",
            "https://i.ebayimg.com/images/g/aJYAAeSwVEtoeS0f/s-l1600.webp",
            "https://i.ebayimg.com/images/g/yRUAAeSwWcpoeS0a/s-l1600.webp",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/12/7522732/2.jpg?1788",
        ],
    },
    {
        "model": "BlackWidow V4",
        "brand": "Razer",
        "images": [
            "https://m.media-amazon.com/images/I/815XJdl7fXL._AC_SL1500_.jpg",
            "https://m.media-amazon.com/images/I/71OEqY51LeL._AC_SL1500_.jpg",
            "https://m.media-amazon.com/images/I/71qntGdDckL._AC_SL1500_.jpg",
            "https://m.media-amazon.com/images/I/81XQaC7vX+L._AC_SL1500_.jpg",
        
        ],
    },
    {
        "model": "K95 RGB",
        "brand": "Corsair",
        "images": [
            "https://media.officedepot.com/images/f_auto,q_auto,e_sharpen,h_450/products/6911521/6911521_o51_cn_11070056/6911521",
            "https://www.devicedeal.com.au/assets/full/CH-9127412-NA.jpg?20210309045805",
            "https://assets.corsair.com/image/upload/c_pad,q_auto,h_1024,w_1024,f_auto/products/Gaming-Keyboards/CH-9127014-JP/Gallery/K95_RGB_PLAT_BLK_JP_01.webp",
            "https://assets.corsair.com/image/upload/f_auto,q_auto/content/CH-9000220-NA-CGK95-RGB-NA-005.png",
        ],
    },
    {
        "model": "Alloy Origins",
        "brand": "HyperX",
        "images": [
            "https://i5.walmartimages.com/seo/HyperX-4P5P3AA-Alloy-Origins-Core-Mechanical-Gaming-Keyboard_4df5779d-037f-4869-bc31-6bdf36aa8f0b.e1bdecb0a054a092f484de42ce2b4701.jpeg",
            "https://m.media-amazon.com/images/I/61laVFbGRsL._AC_SL1000_.jpg",
            "https://m.media-amazon.com/images/I/71mdUyMsUiL._AC_SL1000_.jpg",
            "https://m.media-amazon.com/images/I/71pcPOZxu7L._AC_SL1000_.jpg",
        ],
    },
    {
        "model": "Magic Keyboard",
        "brand": "Apple",
        "images": [
            "https://www.istore.com.ng/cdn/shop/products/mk293z_1200x.jpg?v=1642585074",
            "https://i.ebayimg.com/images/g/sA0AAOSwhwtnDyUq/s-l1600.webp",
            "https://i.ebayimg.com/images/g/y6UAAOSwEqxnDyVr/s-l1600.webp",
            "https://upload.wikimedia.org/wikipedia/commons/9/96/Apple-wireless-keyboard-aluminum-2007.jpg",
        ],
    },
    {
        "model": "Huntsman Mini",
        "brand": "Razer",
        "images": [
            "https://m.media-amazon.com/images/I/618etkLUt9L._AC_SL1500_.jpg",
            "https://m.media-amazon.com/images/I/81MB36DRU5L._AC_SL1500_.jpg",
            "https://m.media-amazon.com/images/I/71z3zl-TbQL._AC_SL1500_.jpg",
            "https://m.media-amazon.com/images/I/71EXApeyE2L._AC_SL1500_.jpg",
        ],
    },
]

bag_models = [
    {
        "model": "Premier Backpack",
        "brand": "Dell",
        "images": [
            "https://i.ebayimg.com/images/g/svoAAeSw4xtpaHY8/s-l960.webp",
            "https://images-cdn.ubuy.co.in/65d04062b060511e3f2353aa-dell-pe-bp-15-20-15-in-premier-backpack.jpg",
            "https://www.tpstech.in/cdn/shop/products/00_cfe28e01-adc0-46f6-b715-7233952883e7.jpg?v=1612878871",
            "https://i.ebayimg.com/images/g/iA8AAeSw7MRpaHY8/s-l1600.webp",
        ],
    },
    {
        "model": "Executive Backpack",
        "brand": "HP",
        "images": [
            "https://i.ebayimg.com/images/g/~UgAAeSw0-ZonB1D/s-l500.webp",
            "https://hp.widen.net/content/jwmmoytuco/webp/jwmmoytuco.png?w=573&h=430&dpi=72&color=ffffff00",
            "https://i.ebayimg.com/images/g/YqIAAeSwi1JonB1D/s-l1600.webp",
            "https://i.ebayimg.com/images/g/VgIAAeSwfVlonB1C/s-l1600.webp",
        ],
    },
    {
        "model": "Legion Backpack",
        "brand": "Lenovo",
        "images": [
            "https://m.media-amazon.com/images/I/518Uaqz6oLL._AC_SL1000_.jpg",
            "https://m.media-amazon.com/images/I/41Kpl01KaBL._AC_SL1000_.jpg",
            "https://m.media-amazon.com/images/I/51WPErPFWRL._AC_SL1000_.jpg",
            "https://m.media-amazon.com/images/I/51jHHyb3I5L._AC_SL1000_.jpg",
        ],
    },
    {
        "model": "Rogue Backpack",
        "brand": "Razer",
        "images": [
            "https://m.media-amazon.com/images/I/41Hq0fqkfaL._SS1000_.jpg",
            "https://m.media-amazon.com/images/I/91MDLn-cRtL._AC_SL1500_.jpg",
            "https://m.media-amazon.com/images/I/71KVO6fqn9L._AC_SL1500_.jpg",
            "https://m.media-amazon.com/images/I/81Cdip7Eo1L._AC_SL1500_.jpg",
        ],
    },
    {
        "model": "ROG Backpack",
        "brand": "Asus",
        "images": [
            "https://dlcdnwebimgs.asus.com/gain/6E7D902B-25CF-4617-8431-2409F2C04155",
            "https://dlcdnwebimgs.asus.com/gain/A7ACF666-A786-4DF5-B893-CC3CC0F79CF4",
            "https://dlcdnwebimgs.asus.com/gain/A7283899-9C20-42DC-956D-72C2A1A92331",
            "https://dlcdnimgs.asus.com/websites/global/products/9boikwzr9rpiu6mf/img/1-aura.png",
        ],
    },
    {
        "model": "Nitro Urban",
        "brand": "Acer",
        "images": [
            "https://m.media-amazon.com/images/I/61laAbb9pnL._AC_UY1100_.jpg",
            "https://media.4rgos.it/s/Argos/4468909_R_SET?$Main768$&w=620&h=620",
            "https://cdn3.evostore.io/productimages/fusion/l/fus_889282b.webp",
            "https://static-ecapac.acer.com/media/catalog/product/w/h/whatsapp_image_2023-10-23_at_11.46.13_zl.bagss.006.jpeg?optimize=high&bg-color=255,255,255&fit=bounds&height=&width=&canvas=:",
            
        ],
    },
]

charger_models = [
    {
        "model": "65W USB-C",
        "brand": "Dell",
        "images": [
            "https://i.ebayimg.com/images/g/M14AAeSw0ERpHhBL/s-l1600.webp",
            "https://static.wixstatic.com/media/6469df_b1a4109dcf524098926abfaa59ebb4c6~mv2.jpg/v1/fill/w_520,h_808,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/6469df_b1a4109dcf524098926abfaa59ebb4c6~mv2.jpg",
            "https://i.ebayimg.com/images/g/5BgAAOSw9N1kMdhs/s-l1600.webp",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/07/2119814/1.jpg?2268",
        ],
    },
    {
        "model": "90W Adapter",
        "brand": "HP",
        "images": [
            "https://i.ebayimg.com/images/g/kcAAAOSwmKZndrcg/s-l1600.webp",
            "https://ssl-product-images.www8-hp.com/digmedialib/prodimg/lowres/c04601770.png",
            "https://i.ebayimg.com/images/g/kcAAAOSwmKZndrcg/s-l1600.webp",
            "https://shopinverse.com/cdn/shop/files/hp-90w-19v-474a-big-mouth-laptop-charger-usa-plug-5620134.jpg?v=1764310753&width=1200",
        ],
    },
    {
        "model": "45W Travel",
        "brand": "Lenovo",
        "images": [
            "https://m.media-amazon.com/images/I/71AgY8q5c2L._AC_SX679_.jpg",
            "https://m.media-amazon.com/images/I/41BYOFVCKLL._AC_UF894,1000_QL80_.jpg",
            "https://m.media-amazon.com/images/I/41BYOFVCKLL._AC_UF894,1000_QL80_.jpg",
            "https://m.media-amazon.com/images/I/712DutBVASL._AC_SL1500_.jpg",
        ],
    },
    {
        "model": "96W USB-C",
        "brand": "Apple",
        "images": [
            "https://i.ebayimg.com/images/g/plsAAeSwtX9oqTVt/s-l1600.webp",
            "https://i.ebayimg.com/images/g/tysAAOSwZRxlyb3I/s-l1600.webp",
            "https://i.ebayimg.com/images/g/rWIAAOSwNSZlyb3J/s-l1600.webp",
            "https://i.ebayimg.com/images/g/MUwAAOSwlGdoCFSp/s-l1600.webp",
        ],
    },
    {
        "model": "65W GaN",
        "brand": "Anker",
        "images": [
            "https://i.ebayimg.com/images/g/zVUAAeSwnBxphF6i/s-l1600.webp",
            "https://i.ebayimg.com/images/g/NRgAAeSwX9hoyY9-/s-l1600.webp",
            "https://i.ebayimg.com/images/g/mbkAAeSws~VoQWtL/s-l1600.webp",
            "https://i.ebayimg.com/images/g/GJEAAeSwDPBo7U0x/s-l1600.webp",
        ],
    },
]

products = []

def slugify(value: str) -> str:
    v = value.strip().lower()
    v = re.sub(r"[^a-z0-9]+", "_", v)
    v = re.sub(r"_+", "_", v).strip("_")
    return v

def normalize_model_data(model_data):
    if isinstance(model_data, dict):
        model_name = str(model_data.get("model") or model_data.get("name") or "").strip()
        brand = str(model_data.get("brand") or "").strip()
        images = model_data.get("images") or model_data.get("imageUrls") or model_data.get("image_urls")
        if isinstance(images, list):
            cleaned = []
            for item in images:
                if isinstance(item, str) and item.strip():
                    cleaned.append(item.strip())
            primary = cleaned[0] if cleaned else ""
            return model_name, brand, primary, cleaned
        primary = str(model_data.get("imageUrl") or model_data.get("image") or "").strip()
        return model_name, brand, primary, []

    if isinstance(model_data, (list, tuple)):
        if len(model_data) == 3 and isinstance(model_data[2], list):
            model_name, brand, images = model_data
            cleaned = [u.strip() for u in images if isinstance(u, str) and u.strip()]
            primary = cleaned[0] if cleaned else ""
            return str(model_name).strip(), str(brand).strip(), primary, cleaned
        if len(model_data) >= 3:
            model_name, brand, img = model_data[0], model_data[1], model_data[2]
            return str(model_name).strip(), str(brand).strip(), str(img).strip(), []

    raise ValueError(f"Unsupported model_data format: {model_data!r}")

def build_image_urls(category: str, primary_url: str, explicit_images=None) -> list[str]:
    unique = []
    seen_bases = set()

    if isinstance(explicit_images, list) and explicit_images:
        cleaned = []
        for url in explicit_images:
            if isinstance(url, str) and url.strip():
                cleaned.append(url.strip())
        if cleaned:
            while len(cleaned) < 4:
                cleaned.append(cleaned[0])
            return cleaned[:4]
        for url in explicit_images:
            if not isinstance(url, str) or not url.strip():
                continue
            base = url.split("?", 1)[0]
            if not base or base in seen_bases:
                continue
            unique.append(url.strip())
            seen_bases.add(base)
            if len(unique) >= 4:
                return unique[:4]
    else:
        primary_base = primary_url.split("?", 1)[0] if isinstance(primary_url, str) else ""
        if primary_base:
            unique.append(primary_url)
            seen_bases.add(primary_base)

    pool_map = globals().get("category_image_pool", {}) or {}
    pool = pool_map.get(category, []) if isinstance(pool_map, dict) else []
    remaining = [u for u in pool if isinstance(u, str) and u.strip()]
    random.shuffle(remaining)
    for url in remaining:
        base = url.split("?", 1)[0]
        if not base or base in seen_bases:
            continue
        unique.append(url)
        seen_bases.add(base)
        if len(unique) >= 4:
            break

    while len(unique) < 4:
        unique.append(primary_url)
    return unique[:4]

def create_product(category, model_data, idx):
    model_name, brand, img, explicit_images = normalize_model_data(model_data)
    clean_id = f"{slugify(category)}_{slugify(brand)}_{slugify(model_name)}"
    
    price = 0
    specs = {}
    
    if category == "Laptop":
        price = random.randint(800, 2500)
        specs = {
            "cpu": random.choice(["Intel i5", "Intel i7", "Ryzen 5", "Ryzen 7", "M1", "M2"]),
            "ram": random.choice(["8GB", "16GB", "32GB"]),
            "storage": random.choice(["256GB SSD", "512GB SSD", "1TB SSD"]),
            "gpu": random.choice(["Intel Iris", "NVIDIA RTX 3050", "NVIDIA RTX 3060", "AMD Radeon"]),
            "display": random.choice(["13.3 inch", "14 inch", "15.6 inch", "16 inch"]),
            "battery": f"{random.randint(8, 15)} hours",
            "weight": f"{random.uniform(1.2, 2.5):.1f} kg"
        }
    elif category == "Mouse":
        price = random.randint(30, 150)
        specs = {
            "connectivity": random.choice(["Bluetooth", "Wireless USB", "Wired"]),
            "dpi": random.randint(1000, 20000),
            "battery": f"{random.randint(1, 12)} months",
            "weight": f"{random.randint(60, 120)} g"
        }
    elif category == "Keyboard":
        price = random.randint(50, 200)
        specs = {
            "type": random.choice(["Mechanical", "Membrane"]),
            "switch": random.choice(["Blue", "Brown", "Red", "None"]),
            "connectivity": random.choice(["USB", "Wireless"]),
            "backlight": random.choice(["RGB", "White", "None"])
        }
    elif category == "Laptop Bag":
        price = random.randint(30, 100)
        specs = {
            "material": random.choice(["Nylon", "Polyester", "Leather"]),
            "capacity": "fits up to 15.6 inch laptop",
            "waterResistant": random.choice([True, False]),
            "weight": f"{random.uniform(0.5, 1.2):.1f} kg"
        }
    elif category == "Charger":
        price = random.randint(20, 80)
        specs = {
            "power": random.choice(["45W", "65W", "90W"]),
            "connector": random.choice(["USB-C", "Barrel"]),
            "voltage": "19.5 V",
            "compatibility": brand
        }

    original_price = None
    if random.random() > 0.7:
        original_price = int(price * random.uniform(1.1, 1.3))

    def clamp_words(text: str, max_words: int = 30) -> str:
        words = re.findall(r"\S+", str(text).strip())
        if len(words) <= max_words:
            return " ".join(words)
        return " ".join(words[:max_words]).rstrip(",.:-;") + "."

    def build_description() -> str:
        highlights = []
        if category == "Laptop":
            highlights = [
                f"{specs.get('cpu', '')}",
                f"{specs.get('ram', '')} RAM",
                f"{specs.get('storage', '')}",
                f"{specs.get('display', '')} display",
            ]
        elif category == "Mouse":
            highlights = [
                f"{specs.get('connectivity', '')}",
                f"{specs.get('dpi', '')} DPI",
                f"battery up to {specs.get('battery', '')}",
            ]
        elif category == "Keyboard":
            highlights = [
                f"{specs.get('type', '')}",
                f"{specs.get('switch', '')} switches",
                f"{specs.get('backlight', '')} backlight",
            ]
        elif category == "Laptop Bag":
            water = "water-resistant" if specs.get("waterResistant") else "everyday"
            highlights = [
                f"{specs.get('material', '')}",
                f"{specs.get('capacity', '')}",
                water,
            ]
        elif category == "Charger":
            highlights = [
                f"{specs.get('power', '')}",
                f"{specs.get('connector', '')}",
                f"for {specs.get('compatibility', brand)}",
            ]

        highlights = [h for h in highlights if str(h).strip() and str(h).strip() != "None"]
        random.shuffle(highlights)
        summary = ", ".join(highlights[:3])

        openers = [
            "Built for daily performance",
            "Designed for speed and comfort",
            "Reliable gear for work and play",
            "A premium pick for productivity",
            "Smart, durable, and ready to go",
        ]
        closer = random.choice(
            [
                "Great for students, creators, and professionals.",
                "Ideal for home, office, and travel.",
                "Clean design with dependable performance.",
                "A solid upgrade for your setup.",
                "Made to keep up with your workflow.",
            ]
        )

        base = f"{random.choice(openers)}. {brand} {model_name} with {summary}. {closer}"
        return clamp_words(base, 30)

    price_ngn = round(float(price) * USD_TO_NGN, 2)
    original_price_ngn = round(float(original_price) * USD_TO_NGN, 2) if original_price else None

    return {
        "id": clean_id,
        "brand": brand,
        "model": model_name,
        "imageUrl": img,
        "imageUrls": build_image_urls(category, img, explicit_images=explicit_images),
        "price": price_ngn,
        "originalPrice": original_price_ngn,
        "description": build_description(),
        "category": category,
        "rating": round(random.uniform(3.5, 5.0), 1),
        "reviewCount": random.randint(10, 500),
        "inStock": True,
        "stock": random.randint(5, 100),
        "specifications": specs
    }

def generate_products():
    items = []

    for i in range(15):
        items.append(create_product("Laptop", laptop_models[i % len(laptop_models)], i))

    for i in range(8):
        items.append(create_product("Mouse", mouse_models[i % len(mouse_models)], i))

    for i in range(6):
        items.append(create_product("Keyboard", keyboard_models[i % len(keyboard_models)], i))

    for i in range(6):
        items.append(create_product("Laptop Bag", bag_models[i % len(bag_models)], i))

    for i in range(5):
        items.append(create_product("Charger", charger_models[i % len(charger_models)], i))

    return {"products": items}

if __name__ == "__main__":
    output = generate_products()
    with open("assets/data/products.json", "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    print(json.dumps(output, indent=2, ensure_ascii=False))
