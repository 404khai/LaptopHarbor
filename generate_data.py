
import json
import random
import re

brands = ["Dell", "HP", "Redmagic", "Lenovo", "Asus", "Acer", "Apple", "Logitech", "Razer", "Corsair", "HyperX", "MSI"]

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
            "https://latalata.ng/image/cache/catalog/Product%20images/Kaybec/laptop/20--700x700.jpg",
            "https://latalata.ng/image/cache/catalog/Product%20images/Kaybec/laptop/20--700x700.jpg",
            "https://latalata.ng/image/cache/catalog/Product%20images/Kaybec/laptop/20--700x700.jpg",
        ],
    },
    {
        "model": "Spectre x360",
        "brand": "HP",
        "images": [
            "https://media.wired.com/photos/59e94f9234ce5c0e0a752e11/master/w_1600%2Cc_limit/SphinxInline.jpg",
            "https://media.wired.com/photos/59e94f9234ce5c0e0a752e11/master/w_1600%2Cc_limit/SphinxInline.jpg",
            "https://media.wired.com/photos/59e94f9234ce5c0e0a752e11/master/w_1600%2Cc_limit/SphinxInline.jpg",
            "https://media.wired.com/photos/59e94f9234ce5c0e0a752e11/master/w_1600%2Cc_limit/SphinxInline.jpg",
        ],
    },
    {
        "model": "Omen Max 16",
        "brand": "HP",
        "images": [
            "https://pcplaceng.com/laxgts/2025/10/image-2025-10-13T104359.962.webp",
            "https://pcplaceng.com/laxgts/2025/10/image-2025-10-13T104359.962.webp",
            "https://pcplaceng.com/laxgts/2025/10/image-2025-10-13T104359.962.webp",
            "https://pcplaceng.com/laxgts/2025/10/image-2025-10-13T104359.962.webp",
        ],
    },
    {
        "model": "ThinkPad X1 Carbon",
        "brand": "Lenovo",
        "images": [
            "https://pacific.com.ng/wp-content/uploads/2022/09/Lenovo-thinkpad-x1-carbon.webp",
            "https://pacific.com.ng/wp-content/uploads/2022/09/Lenovo-thinkpad-x1-carbon.webp",
            "https://pacific.com.ng/wp-content/uploads/2022/09/Lenovo-thinkpad-x1-carbon.webp",
            "https://pacific.com.ng/wp-content/uploads/2022/09/Lenovo-thinkpad-x1-carbon.webp",
        ],
    },
    {
        "model": "Yoga 9i",
        "brand": "Lenovo",
        "images": [
            "https://i5.walmartimages.com/asr/11a72c12-a798-4029-98a5-2bd8dd25837b.fae5315625c1a8f68a67a61eb40a73e5.jpeg?odnHeight=768&odnWidth=768&odnBg=FFFFFF",
            "https://i5.walmartimages.com/asr/11a72c12-a798-4029-98a5-2bd8dd25837b.fae5315625c1a8f68a67a61eb40a73e5.jpeg?odnHeight=768&odnWidth=768&odnBg=FFFFFF",
            "https://i5.walmartimages.com/asr/11a72c12-a798-4029-98a5-2bd8dd25837b.fae5315625c1a8f68a67a61eb40a73e5.jpeg?odnHeight=768&odnWidth=768&odnBg=FFFFFF",
            "https://i5.walmartimages.com/asr/11a72c12-a798-4029-98a5-2bd8dd25837b.fae5315625c1a8f68a67a61eb40a73e5.jpeg?odnHeight=768&odnWidth=768&odnBg=FFFFFF",
        ],
    },
    {
        "model": "MacBook Air M2",
        "brand": "Apple",
        "images": [
            "https://http2.mlstatic.com/D_NQ_NP_829649-MLA99482022282_112025-O.webp",
            "https://http2.mlstatic.com/D_NQ_NP_829649-MLA99482022282_112025-O.webp",
            "https://http2.mlstatic.com/D_NQ_NP_829649-MLA99482022282_112025-O.webp",
            "https://http2.mlstatic.com/D_NQ_NP_829649-MLA99482022282_112025-O.webp",
        ],
    },
    {
        "model": "MacBook M4 Pro",
        "brand": "Apple",
        "images": [
            "https://i.ebayimg.com/images/g/0Z4AAeSwDKNppUln/s-l1600.webp",
            "https://i.ebayimg.com/images/g/0Z4AAeSwDKNppUln/s-l1600.webp",
            "https://i.ebayimg.com/images/g/0Z4AAeSwDKNppUln/s-l1600.webp",
            "https://i.ebayimg.com/images/g/0Z4AAeSwDKNppUln/s-l1600.webp",
        ],
    },
    {
        "model": "Titan 16 Pro",
        "brand": "Redmagic",
        "images": [
            "https://techxreviews.com/wp-content/uploads/2025/11/RedMagic-Titan-16-Pro-2026.mp4_snapshot_08.32.jpg",
            "https://techxreviews.com/wp-content/uploads/2025/11/RedMagic-Titan-16-Pro-2026.mp4_snapshot_08.32.jpg",
            "https://techxreviews.com/wp-content/uploads/2025/11/RedMagic-Titan-16-Pro-2026.mp4_snapshot_08.32.jpg",
            "https://techxreviews.com/wp-content/uploads/2025/11/RedMagic-Titan-16-Pro-2026.mp4_snapshot_08.32.jpg",
        ],
    },
    {
        "model": "ZenBook 14",
        "brand": "Asus",
        "images": [
            "https://m.media-amazon.com/images/I/51YleVEDxlL.jpg",
            "https://m.media-amazon.com/images/I/51YleVEDxlL.jpg",
            "https://m.media-amazon.com/images/I/51YleVEDxlL.jpg",
            "https://m.media-amazon.com/images/I/51YleVEDxlL.jpg",
        ],
    },
    {
        "model": "ROG Zephyrus G14",
        "brand": "Asus",
        "images": [
            "https://www.myfixguide.com/wp-content/uploads/2024/02/ASUS-ROG-Zephyrus-G14-2024-4.png",
            "https://www.myfixguide.com/wp-content/uploads/2024/02/ASUS-ROG-Zephyrus-G14-2024-4.png",
            "https://www.myfixguide.com/wp-content/uploads/2024/02/ASUS-ROG-Zephyrus-G14-2024-4.png",
            "https://www.myfixguide.com/wp-content/uploads/2024/02/ASUS-ROG-Zephyrus-G14-2024-4.png",
        ],
    },
    {
        "model": "Blade 16",
        "brand": "Razer",
        "images": [
            "https://cdn.mos.cms.futurecdn.net/DECuWxUeCCUtSqgWrHTkkH.jpg",
            "https://cdn.mos.cms.futurecdn.net/DECuWxUeCCUtSqgWrHTkkH.jpg",
            "https://cdn.mos.cms.futurecdn.net/DECuWxUeCCUtSqgWrHTkkH.jpg",
            "https://cdn.mos.cms.futurecdn.net/DECuWxUeCCUtSqgWrHTkkH.jpg",
        ],
    },
    {
        "model": "Alienware M16 R2",
        "brand": "Dell",
        "images": [
            "https://cdn.mos.cms.futurecdn.net/ht4C4qRVGg5NnwQm3WLsrK.jpg",
            "https://cdn.mos.cms.futurecdn.net/ht4C4qRVGg5NnwQm3WLsrK.jpg",
            "https://cdn.mos.cms.futurecdn.net/ht4C4qRVGg5NnwQm3WLsrK.jpg",
            "https://cdn.mos.cms.futurecdn.net/ht4C4qRVGg5NnwQm3WLsrK.jpg",
        ],
    },
    {
        "model": "Predator Helios 16",
        "brand": "Acer",
        "images": [
            "https://microless.com/cdn/products/4679201588f65ddb18a82503b988e760-hi.jpg",
            "https://microless.com/cdn/products/4679201588f65ddb18a82503b988e760-hi.jpg",
            "https://microless.com/cdn/products/4679201588f65ddb18a82503b988e760-hi.jpg",
            "https://microless.com/cdn/products/4679201588f65ddb18a82503b988e760-hi.jpg",
        ],
    },
    {
        "model": "Stealth 15M",
        "brand": "MSI",
        "images": [
            "https://storage-asset.msi.com/global/picture/product/product_1647299935ac38d9de46efa12c710a7e56c5da2a60.webp",
            "https://storage-asset.msi.com/global/picture/product/product_1647299935ac38d9de46efa12c710a7e56c5da2a60.webp",
            "https://storage-asset.msi.com/global/picture/product/product_1647299935ac38d9de46efa12c710a7e56c5da2a60.webp",
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
            "https://resource.logitech.com/c_fill,q_auto,f_auto,dpr_1.0/d_transparent.gif/content/dam/logitech/en/products/mice/mx-master-3s/migration-assets-for-delorean-2025/gallery/mx-master-3s-top-view-graphite.png",
            "https://resource.logitech.com/c_fill,q_auto,f_auto,dpr_1.0/d_transparent.gif/content/dam/logitech/en/products/mice/mx-master-3s/migration-assets-for-delorean-2025/gallery/mx-master-3s-top-view-graphite.png",
            "https://resource.logitech.com/c_fill,q_auto,f_auto,dpr_1.0/d_transparent.gif/content/dam/logitech/en/products/mice/mx-master-3s/migration-assets-for-delorean-2025/gallery/mx-master-3s-top-view-graphite.png",
        ],
    },
    {
        "model": "G502 Hero",
        "brand": "Logitech",
        "images": [
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/33/0548852/1.jpg?8470",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/33/0548852/1.jpg?8470",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/33/0548852/1.jpg?8470",
            "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/33/0548852/1.jpg?8470",
        ],
    },
    {
        "model": "DeathAdder V3",
        "brand": "Razer",
        "images": [
            "https://www.pbtech.com/pacific/imgprod/M/S/MSERAZ87084__1.jpg",
            "https://www.pbtech.com/pacific/imgprod/M/S/MSERAZ87084__1.jpg",
            "https://www.pbtech.com/pacific/imgprod/M/S/MSERAZ87084__1.jpg",
            "https://www.pbtech.com/pacific/imgprod/M/S/MSERAZ87084__1.jpg",
        ],
    },
    {
        "model": "Basilisk V3",
        "brand": "Razer",
        "images": [
            "https://i.rtings.com/assets/products/HlSiCAs0/razer-basilisk-v3/design-medium.jpg?format=auto",
            "https://i.rtings.com/assets/products/HlSiCAs0/razer-basilisk-v3/design-medium.jpg?format=auto",
            "https://i.rtings.com/assets/products/HlSiCAs0/razer-basilisk-v3/design-medium.jpg?format=auto",
            "https://i.rtings.com/assets/products/HlSiCAs0/razer-basilisk-v3/design-medium.jpg?format=auto",
        ],
    },
    {
        "model": "Dark Core RGB",
        "brand": "Corsair",
        "images": [
            "https://assets.corsair.com/image/upload/c_pad,q_auto,h_1024,w_1024,f_auto/products/Gaming-Mice/CH-9315311-NA/Gallery/DARK_CORE_RGB_SE_01.webp",
            "https://assets.corsair.com/image/upload/c_pad,q_auto,h_1024,w_1024,f_auto/products/Gaming-Mice/CH-9315311-NA/Gallery/DARK_CORE_RGB_SE_01.webp",
            "https://assets.corsair.com/image/upload/c_pad,q_auto,h_1024,w_1024,f_auto/products/Gaming-Mice/CH-9315311-NA/Gallery/DARK_CORE_RGB_SE_01.webp",
            "https://assets.corsair.com/image/upload/c_pad,q_auto,h_1024,w_1024,f_auto/products/Gaming-Mice/CH-9315311-NA/Gallery/DARK_CORE_RGB_SE_01.webp",
        ],
    },
    {
        "model": "Pulsefire Haste",
        "brand": "HyperX",
        "images": [
            "https://row.hyperx.com/cdn/shop/files/hyperx_pulsefire_haste_wireless_black_1_top_down.jpg?v=1700189384",
            "https://row.hyperx.com/cdn/shop/files/hyperx_pulsefire_haste_wireless_black_1_top_down.jpg?v=1700189384",
            "https://row.hyperx.com/cdn/shop/files/hyperx_pulsefire_haste_wireless_black_1_top_down.jpg?v=1700189384",
            "https://row.hyperx.com/cdn/shop/files/hyperx_pulsefire_haste_wireless_black_1_top_down.jpg?v=1700189384",
        ],
    },
    {
        "model": "Magic Mouse 2",
        "brand": "Apple",
        "images": [
            "https://i.ebayimg.com/images/g/zLoAAOSwwclmbhXh/s-l1200.jpg",
            "https://i.ebayimg.com/images/g/zLoAAOSwwclmbhXh/s-l1200.jpg",
            "https://i.ebayimg.com/images/g/zLoAAOSwwclmbhXh/s-l1200.jpg",
            "https://i.ebayimg.com/images/g/zLoAAOSwwclmbhXh/s-l1200.jpg",
        ],
    },
    {
        "model": "Viper Ultimate",
        "brand": "Razer",
        "images": [
            "https://m.media-amazon.com/images/I/61M2OwtouxL.jpg",
            "https://m.media-amazon.com/images/I/61M2OwtouxL.jpg",
            "https://m.media-amazon.com/images/I/61M2OwtouxL.jpg",
            "https://m.media-amazon.com/images/I/61M2OwtouxL.jpg",
        ],
    },
]

keyboard_models = [
    {
        "model": "MX Keys",
        "brand": "Logitech",
        "images": [
            "https://media.stockinthechannel.com/pic/60qDoO-C3ka2PVvCRStM8A.c-r.jpg",
            "https://media.stockinthechannel.com/pic/60qDoO-C3ka2PVvCRStM8A.c-r.jpg",
            "https://media.stockinthechannel.com/pic/60qDoO-C3ka2PVvCRStM8A.c-r.jpg",
            "https://media.stockinthechannel.com/pic/60qDoO-C3ka2PVvCRStM8A.c-r.jpg",
        ],
    },
    {
        "model": "BlackWidow V4",
        "brand": "Razer",
        "images": [
            "https://m.media-amazon.com/images/I/815XJdl7fXL._AC_SL1500_.jpg",
            "https://m.media-amazon.com/images/I/815XJdl7fXL._AC_SL1500_.jpg",
            "https://m.media-amazon.com/images/I/815XJdl7fXL._AC_SL1500_.jpg",
            "https://m.media-amazon.com/images/I/815XJdl7fXL._AC_SL1500_.jpg",
        ],
    },
    {
        "model": "K95 RGB",
        "brand": "Corsair",
        "images": [
            "https://www.devicedeal.com.au/assets/full/CH-9127412-NA.jpg?20210309045805",
            "https://www.devicedeal.com.au/assets/full/CH-9127412-NA.jpg?20210309045805",
            "https://www.devicedeal.com.au/assets/full/CH-9127412-NA.jpg?20210309045805",
            "https://www.devicedeal.com.au/assets/full/CH-9127412-NA.jpg?20210309045805",
        ],
    },
    {
        "model": "Alloy Origins",
        "brand": "HyperX",
        "images": [
            "https://i5.walmartimages.com/seo/HyperX-4P5P3AA-Alloy-Origins-Core-Mechanical-Gaming-Keyboard_4df5779d-037f-4869-bc31-6bdf36aa8f0b.e1bdecb0a054a092f484de42ce2b4701.jpeg",
            "https://i5.walmartimages.com/seo/HyperX-4P5P3AA-Alloy-Origins-Core-Mechanical-Gaming-Keyboard_4df5779d-037f-4869-bc31-6bdf36aa8f0b.e1bdecb0a054a092f484de42ce2b4701.jpeg",
            "https://i5.walmartimages.com/seo/HyperX-4P5P3AA-Alloy-Origins-Core-Mechanical-Gaming-Keyboard_4df5779d-037f-4869-bc31-6bdf36aa8f0b.e1bdecb0a054a092f484de42ce2b4701.jpeg",
            "https://i5.walmartimages.com/seo/HyperX-4P5P3AA-Alloy-Origins-Core-Mechanical-Gaming-Keyboard_4df5779d-037f-4869-bc31-6bdf36aa8f0b.e1bdecb0a054a092f484de42ce2b4701.jpeg",
        ],
    },
    {
        "model": "Magic Keyboard",
        "brand": "Apple",
        "images": [
            "https://www.istore.com.ng/cdn/shop/products/mk293z_1200x.jpg?v=1642585074",
            "https://www.istore.com.ng/cdn/shop/products/mk293z_1200x.jpg?v=1642585074",
            "https://www.istore.com.ng/cdn/shop/products/mk293z_1200x.jpg?v=1642585074",
            "https://www.istore.com.ng/cdn/shop/products/mk293z_1200x.jpg?v=1642585074",
        ],
    },
    {
        "model": "Huntsman Mini",
        "brand": "Razer",
        "images": [
            "https://i.pcmag.com/imagery/reviews/04WneWB1tIjQfk7lA9D6vu1-1.fit_lim.size_1050x.png",
            "https://i.pcmag.com/imagery/reviews/04WneWB1tIjQfk7lA9D6vu1-1.fit_lim.size_1050x.png",
            "https://i.pcmag.com/imagery/reviews/04WneWB1tIjQfk7lA9D6vu1-1.fit_lim.size_1050x.png",
            "https://i.pcmag.com/imagery/reviews/04WneWB1tIjQfk7lA9D6vu1-1.fit_lim.size_1050x.png",
        ],
    },
]

bag_models = [
    {
        "model": "Premier Backpack",
        "brand": "Dell",
        "images": [
            "https://images-cdn.ubuy.co.in/65d04062b060511e3f2353aa-dell-pe-bp-15-20-15-in-premier-backpack.jpg",
            "https://images-cdn.ubuy.co.in/65d04062b060511e3f2353aa-dell-pe-bp-15-20-15-in-premier-backpack.jpg",
            "https://images-cdn.ubuy.co.in/65d04062b060511e3f2353aa-dell-pe-bp-15-20-15-in-premier-backpack.jpg",
            "https://images-cdn.ubuy.co.in/65d04062b060511e3f2353aa-dell-pe-bp-15-20-15-in-premier-backpack.jpg",
        ],
    },
    {
        "model": "Executive Backpack",
        "brand": "HP",
        "images": [
            "https://hp.widen.net/content/jwmmoytuco/webp/jwmmoytuco.png?w=573&h=430&dpi=72&color=ffffff00",
            "https://hp.widen.net/content/jwmmoytuco/webp/jwmmoytuco.png?w=573&h=430&dpi=72&color=ffffff00",
            "https://hp.widen.net/content/jwmmoytuco/webp/jwmmoytuco.png?w=573&h=430&dpi=72&color=ffffff00",
            "https://hp.widen.net/content/jwmmoytuco/webp/jwmmoytuco.png?w=573&h=430&dpi=72&color=ffffff00",
        ],
    },
    {
        "model": "Legion Backpack",
        "brand": "Lenovo",
        "images": [
            "https://i5.walmartimages.com/seo/Legion-15-6-Recon-Gaming-Backpack_6efa108a-a7bb-4f2f-a10d-1b2765e0cc75.5b217f5ac6b65f6cb958bb6269791095.jpeg",
            "https://i5.walmartimages.com/seo/Legion-15-6-Recon-Gaming-Backpack_6efa108a-a7bb-4f2f-a10d-1b2765e0cc75.5b217f5ac6b65f6cb958bb6269791095.jpeg",
            "https://i5.walmartimages.com/seo/Legion-15-6-Recon-Gaming-Backpack_6efa108a-a7bb-4f2f-a10d-1b2765e0cc75.5b217f5ac6b65f6cb958bb6269791095.jpeg",
            "https://i5.walmartimages.com/seo/Legion-15-6-Recon-Gaming-Backpack_6efa108a-a7bb-4f2f-a10d-1b2765e0cc75.5b217f5ac6b65f6cb958bb6269791095.jpeg",
        ],
    },
    {
        "model": "Rogue Backpack",
        "brand": "Razer",
        "images": [
            "https://m.media-amazon.com/images/I/41Hq0fqkfaL._SS1000_.jpg",
            "https://m.media-amazon.com/images/I/41Hq0fqkfaL._SS1000_.jpg",
            "https://m.media-amazon.com/images/I/41Hq0fqkfaL._SS1000_.jpg",
            "https://m.media-amazon.com/images/I/41Hq0fqkfaL._SS1000_.jpg",
        ],
    },
    {
        "model": "ROG Backpack",
        "brand": "Asus",
        "images": [
            "https://m.media-amazon.com/images/I/317hWqS4bWS._AC_SR218_.jpg",
            "https://m.media-amazon.com/images/I/317hWqS4bWS._AC_SR218_.jpg",
            "https://m.media-amazon.com/images/I/317hWqS4bWS._AC_SR218_.jpg",
            "https://m.media-amazon.com/images/I/317hWqS4bWS._AC_SR218_.jpg",
        ],
    },
    {
        "model": "Nitro Urban",
        "brand": "Acer",
        "images": [
            "https://media.4rgos.it/s/Argos/4468909_R_SET?$Main768$&w=620&h=620",
            "https://media.4rgos.it/s/Argos/4468909_R_SET?$Main768$&w=620&h=620",
            "https://media.4rgos.it/s/Argos/4468909_R_SET?$Main768$&w=620&h=620",
            "https://media.4rgos.it/s/Argos/4468909_R_SET?$Main768$&w=620&h=620",
        ],
    },
]

charger_models = [
    {
        "model": "65W USB-C",
        "brand": "Dell",
        "images": [
            "https://static.wixstatic.com/media/6469df_b1a4109dcf524098926abfaa59ebb4c6~mv2.jpg/v1/fill/w_520,h_808,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/6469df_b1a4109dcf524098926abfaa59ebb4c6~mv2.jpg",
            "https://static.wixstatic.com/media/6469df_b1a4109dcf524098926abfaa59ebb4c6~mv2.jpg/v1/fill/w_520,h_808,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/6469df_b1a4109dcf524098926abfaa59ebb4c6~mv2.jpg",
            "https://static.wixstatic.com/media/6469df_b1a4109dcf524098926abfaa59ebb4c6~mv2.jpg/v1/fill/w_520,h_808,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/6469df_b1a4109dcf524098926abfaa59ebb4c6~mv2.jpg",
            "https://static.wixstatic.com/media/6469df_b1a4109dcf524098926abfaa59ebb4c6~mv2.jpg/v1/fill/w_520,h_808,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/6469df_b1a4109dcf524098926abfaa59ebb4c6~mv2.jpg",
        ],
    },
    {
        "model": "90W Adapter",
        "brand": "HP",
        "images": [
            "https://ssl-product-images.www8-hp.com/digmedialib/prodimg/lowres/c04601770.png",
            "https://ssl-product-images.www8-hp.com/digmedialib/prodimg/lowres/c04601770.png",
            "https://ssl-product-images.www8-hp.com/digmedialib/prodimg/lowres/c04601770.png",
            "https://ssl-product-images.www8-hp.com/digmedialib/prodimg/lowres/c04601770.png",
        ],
    },
    {
        "model": "45W Travel",
        "brand": "Lenovo",
        "images": [
            "https://m.media-amazon.com/images/I/41BYOFVCKLL._AC_UF894,1000_QL80_.jpg",
            "https://m.media-amazon.com/images/I/41BYOFVCKLL._AC_UF894,1000_QL80_.jpg",
            "https://m.media-amazon.com/images/I/41BYOFVCKLL._AC_UF894,1000_QL80_.jpg",
            "https://m.media-amazon.com/images/I/41BYOFVCKLL._AC_UF894,1000_QL80_.jpg",
        ],
    },
    {
        "model": "96W USB-C",
        "brand": "Apple",
        "images": [
            "https://i.ebayimg.com/images/g/plsAAeSwtX9oqTVt/s-l1600.webp",
            "https://i.ebayimg.com/images/g/plsAAeSwtX9oqTVt/s-l1600.webp",
            "https://i.ebayimg.com/images/g/plsAAeSwtX9oqTVt/s-l1600.webp",
            "https://i.ebayimg.com/images/g/plsAAeSwtX9oqTVt/s-l1600.webp",
        ],
    },
    {
        "model": "65W GaN",
        "brand": "Anker",
        "images": [
            "https://i.ebayimg.com/images/g/zVUAAeSwnBxphF6i/s-l1600.webp",
            "https://i.ebayimg.com/images/g/zVUAAeSwnBxphF6i/s-l1600.webp",
            "https://i.ebayimg.com/images/g/zVUAAeSwnBxphF6i/s-l1600.webp",
            "https://i.ebayimg.com/images/g/zVUAAeSwnBxphF6i/s-l1600.webp",
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
    pool = category_image_pool.get(category, [])
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

    return {
        "id": clean_id,
        "brand": brand,
        "model": model_name,
        "imageUrl": img,
        "imageUrls": build_image_urls(category, img, explicit_images=explicit_images),
        "price": float(price),
        "originalPrice": float(original_price) if original_price else None,
        "description": f"High quality {category.lower()} from {brand}. Perfect for daily use and professional tasks.",
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
