/* Sample programmes for the mobile concept. Names in every row are existing friends. */
(() => {
  const extraEvents = {
    murazzi: {title:'Un salto ai Murazzi',place:'Murazzi del Po, Torino',date:'Mercoledì 23 settembre',short:'MER 23 SET',time:'22:00 – 00:30',total:18,friends:['Leo']},
    jazz: {title:'Jazz dopo cena',place:'Jazz Club Torino',date:'Giovedì 24 settembre',short:'GIO 24 SET',time:'22:30 – 00:30',total:31,friends:['Vale','Fra']}
  };
  const friendPlans = {
    valentino: {title:'Due passi al Valentino',place:'Parco del Valentino',date:'2026-09-23',time:'17:30',end:'19:00',friends:['Vale'],note:'Vale farà un giro al parco dopo il lavoro.'},
    caffe: {title:'Un caffè in centro',place:'Caffè Elena · Piazza Vittorio',date:'2026-09-24',time:'18:00',end:'19:00',friends:['Fra'],note:'Fra sarà in centro prima di uscire.'},
    brunch: {title:'Brunch della domenica',place:'San Salvario',date:'2026-09-27',time:'11:00',end:'13:00',friends:['Vale','Leo'],note:'Vale e Leo si vedranno per brunch.'}
  };
  const sample = [
    {type:'friend',id:'valentino',date:'2026-09-23',time:'17:30'},
    {type:'event',id:'aperitivo',date:'2026-09-23',time:'19:00'},
    {type:'event',id:'murazzi',date:'2026-09-23',time:'22:00'},
    {type:'friend',id:'caffe',date:'2026-09-24',time:'18:00'},
    {type:'event',id:'coguaro',date:'2026-09-24',time:'21:00'},
    {type:'event',id:'jazz',date:'2026-09-24',time:'22:30'},
    {type:'event',id:'concerto',date:'2026-09-25',time:'20:30'},
    {type:'event',id:'sabato',date:'2026-09-26',time:'18:30'},
    {type:'invite',id:'fra',date:'2026-09-26',time:'20:30'},
    {type:'friend',id:'brunch',date:'2026-09-27',time:'11:00'}
  ];
  const dayDates = {
    '2026-09-23':'Mercoledì 23 settembre',
    '2026-09-24':'Giovedì 24 settembre',
    '2026-09-25':'Venerdì 25 settembre',
    '2026-09-26':'Sabato 26 settembre',
    '2026-09-27':'Domenica 27 settembre'
  };
  function dayFor(date){
    if(date==='2026-09-23')return 'today';
    if(date==='2026-09-24')return 'tomorrow';
    if(date>='2026-09-25'&&date<='2026-09-27')return 'weekend';
    return null;
  }
  function itemsFor(day,state){
    const items=sample.filter(item=>!day||dayFor(item.date)===day).map(item=>({...item}));
    state.plans.forEach((plan,index)=>{
      if(!day||dayFor(plan.date)===day)items.push({type:'own',id:index,date:plan.date,time:plan.start||'00:00'});
    });
    state.createdEvents.forEach((event,index)=>{
      if(!day||dayFor(event.date)===day)items.push({type:'created',id:index,date:event.date,time:event.time||'00:00'});
    });
    items.sort((a,b)=>(a.date+'T'+a.time).localeCompare(b.date+'T'+b.time));
    return items;
  }
  function details(item,opts){
    const {state,events,rsvps}=opts;
    if(item.type==='event'){
      const event=events[item.id];
      return {title:event.title,kind:'Evento pubblico',sub:event.place+' · '+event.friends.length+' amici · '+(event.total+(rsvps[item.id]?1:0))+' partecipanti',action:'event:'+item.id};
    }
    if(item.type==='friend'){
      const plan=friendPlans[item.id];
      return {title:plan.title,kind:'Piano di amici',sub:plan.place+' · '+plan.friends.join(' e '),action:'friend-plan:'+item.id};
    }
    if(item.type==='invite'){
      return {title:'La serata è da Fra',kind:'Invito privato',sub:'Casa di Fra · '+(12+(state.privateResponses?.sample?.joined?1:0))+' partecipanti',action:'sample-invite'};
    }
    if(item.type==='own'){
      const plan=state.plans[item.id];
      return {title:plan.place,kind:'Il tuo piano',sub:plan.visibility==='private'?'Visibile solo a te':'Visibile ai tuoi amici',action:'own-plan:'+item.id};
    }
    const event=state.createdEvents[item.id];
    return {title:event.title,kind:'Organizzi tu',sub:event.place+' · '+(event.visibility==='private'?'su invito':'pubblico'),action:'managed:'+item.id};
  }
  function row(item,opts){
    const info=details(item,opts),safe=opts.esc,arrow=opts.icon('chevron-right');
    return '<button class="plan-entry cursor-interaction" type="button" data-action="'+safe(info.action)+'" aria-label="'+safe(info.title+', '+item.time+', '+info.sub)+'">'+
      '<span class="plan-time">'+safe(item.time)+'<small>'+safe(item.type==='own'?'Tu':'Torino')+'</small></span>'+
      '<span class="plan-copy"><small class="plan-type">'+safe(info.kind)+'</small><strong>'+safe(info.title)+'</strong><small>'+safe(info.sub)+'</small></span>'+arrow+'</button>';
  }
  function renderDay(day,opts){
    const items=itemsFor(day,opts.state);
    let out='',lastDate='';
    for(const item of items){
      if(day==='weekend'&&item.date!==lastDate)out+='<p class="feed-day">'+opts.esc(dayDates[item.date]||item.date)+'</p>';
      out+=row(item,opts);lastDate=item.date;
    }
    return '<div class="plan-feed'+(day==='weekend'?' week-list':'')+'">'+out+'</div>';
  }
  function renderWeek(opts){
    const items=itemsFor(null,opts.state),groups={};
    for(const item of items)(groups[item.date]??=[]).push(item);
    return Object.keys(groups).sort().map(date=>
      '<section class="week-group"><p class="feed-day">'+opts.esc(dayDates[date]||date)+'</p><div class="plan-feed">'+groups[date].map(item=>row(item,opts)).join('')+'</div></section>'
    ).join('');
  }
  function friendDetail(id,helpers){
    const plan=friendPlans[id],{back,icon,button,esc}=helpers;
    if(!plan)return '';
    return back('Il piano degli amici',helpers.origin)+
      '<div class="title-block"><p class="eyebrow">Solo amici</p><h1 style="margin-top:9px">'+esc(plan.title)+'</h1><p>'+esc(plan.note)+'</p></div>'+
      '<div class="info-row">'+icon('calendar-days')+'<div><p>'+esc(dayDates[plan.date])+'</p><small>'+esc(plan.time+' – '+plan.end)+'</small></div></div>'+
      '<div class="info-row">'+icon('map-pin')+'<div><p>'+esc(plan.place)+'</p><small>Torino</small></div></div>'+
      '<div class="section-title"><h2>Amici che ci saranno</h2><span class="feed-summary">'+plan.friends.length+' visibili</span></div>'+
      plan.friends.map(name=>helpers.person(name,'Ha condiviso questo piano')).join('')+
      '<p class="privacy">'+icon('lock-keyhole')+'<span>Questo piano è condiviso solo con gli amici.</span></p>'+
      button('Ci sarò anch’io '+icon('arrow-right'),'join-friend:'+id);
  }
  globalThis.FuoriPlanFeed={extraEvents,friendPlans,itemsFor,renderDay,renderWeek,friendDetail};
})();
